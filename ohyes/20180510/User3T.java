package com.pengkong.boatrace.simulation;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.pengkong.boatrace.common.BoatProperty;
import com.pengkong.boatrace.model.OddsTItem;
import com.pengkong.boatrace.model.PopularItem;
import com.pengkong.boatrace.model.comparator.PopularReverseComparator;
import com.pengkong.boatrace.service.manager.OddsManager;
import com.pengkong.boatrace.service.manager.PopularManager;
import com.pengkong.boatrace.util.BoatUtil;
import com.pengkong.common.FileUtil;

public class User3T extends UserBase {
	private Logger logger = LoggerFactory.getLogger(User3T.class);

	int popularItemCount = 0;
	
	public User3T(String fromYmd, String toYmd, BettingRule rule) {
		super();
		this.fromYmd = fromYmd;
		this.toYmd = toYmd;
		this.rule = rule;
	}

	@Override
	public void doDailyBet(String ymd) throws Exception {
		OddsManager.getInstance().load(ymd);

		loadRaces(ymd);

		for (JyoStatus jyoStatus : mapByJyo.values()) {
			if (jyoStatus.status == JyoStatus.STATUS_OPEN) {
				popularItemCount += jyoStatus.popularItemCount;
			}
		}
		
		if (jyoCount <= 0) {
			return;
		}
		betCount = 0;
		
		// 締切時間でソート
		raceList.sort((RaceEx r1, RaceEx r2) -> r1.sortTime - r2.sortTime);
		int i = 0;
		// for (i = 0; i < raceList.size(); i++) {
		while (i < raceList.size()) {
			RaceEx race = raceList.get(i);
			i++;

			JyoStatus jyoStatus = mapByJyo.get(race.setu.jyoCd);

			// 場終了
			if (jyoStatus.status == JyoStatus.STATUS_CLOSED) {
				continue;
			}
			if (race.status == RaceEx.STATUS_CLOSED) {
				continue;
			} else if (race.status == RaceEx.STATUS_WAIT) {
				try {
					// BETTING!!!
					race = doBet(race);
					
				} catch (Exception e) {
					logger.error("doBet failed!", e);
					jyoStatus.popularItemCount--;
					jyoStatus.skipCount++;
					race.skip = "エラー";
					race.status = RaceEx.STATUS_CLOSED;
					writeRaceInformation(jyoStatus, race);
					continue;
				}
				jyoStatus.popularItemCount--;

				// ベッティングなし
				if (race.betlist.size() == 0) {
					jyoStatus.skipCount++;
					race.skip = "スキップ";
					race.status = RaceEx.STATUS_CLOSED;
					writeRaceInformation(jyoStatus, race);
					continue;
				}

				int betMoney = race.getBetMoney();
				// 残高確認
				if ((balance - betMoney) <= 0) {
					logger.error("破産...");
					System.exit(-1);
				}

				// 残高更新
				balance -= betMoney;
				jyoStatus.totalBetAmount += betMoney;
				jyoStatus.betCount++;
				if (race.multiplyType == RaceEx.MULTIPLY_MARTIN) {
					jyoStatus.martinCount++;
					jyoStatus.martinLoss += betMoney;
				}

				// 結果確認用再スケジューリング
				race = setSortTime(race);
				race.status = RaceEx.STATUS_BETTING;
				raceList.sort((RaceEx r1, RaceEx r2) -> r1.sortTime - r2.sortTime);
				betCount++;
				// 再スタート
				i = 0;

			} else if (race.status == RaceEx.STATUS_BETTING) {
				try {
					// 払戻取得
					race.prize = doResult(race);
				} catch (Exception e) {
					logger.error("doResult failed!", e);
					jyoStatus.skipCount++;
					race.skip = "エラー";
					race.status = RaceEx.STATUS_CLOSED;
					writeRaceInformation(jyoStatus, race);
					continue;
				}
				// 残高更新
				if (race.prize > 0) {
					// 払戻あり
					jyoStatus.hitCount++;
					jyoStatus.totalPrizeAmount += race.prize;
					balance += race.prize;
					jyoStatus.lossAmount -= race.prize;
					if (jyoStatus.lossAmount < 0) {
						jyoStatus.lossAmount = 0;
					}

					// マーティン法カウンタ解除
					if (race.multiplyType == RaceEx.MULTIPLY_MARTIN) {
						jyoStatus.martinCount = 0;
						jyoStatus.martinLoss = 0;
						jyoStatus.martinDailySuccessCount++;
						
						if (rule.getString("martinRestrictSuccess").equals("Y")) {
							// マーティ法回数制限による直中止判定
							jyoStatus.status = JyoStatus.STATUS_MARTIN_RESET_RESTRICT;
						}
					}
				} else {
					if (race.multiplyType == RaceEx.MULTIPLY_MARTIN) {
						if (jyoStatus.martinCount >= rule.getInt("martinCountLimit")) {
							jyoStatus.martinCount = 0;
							jyoStatus.martinLoss = 0;
							jyoStatus.martinDailyFailCount++;
							// マーティ法最大金額超過
							//jyoStatus.status = JyoStatus.STATUS_MARTIN_AMOUNT_RESTRICT;
						}
					} else {
						if (rule.getInt("martinCountLimit") > 0) {
							jyoStatus.martinLoss = race.getBetMoney();  //race.betlist.get(0).money;  // ////// //  // //// 
						}
					}
					jyoStatus.lossAmount += race.getBetMoney();
					jyoStatus.totalLossAmount += race.getBetMoney();
				}

				race.status = RaceEx.STATUS_CLOSED;
				writeRaceInformation(jyoStatus, race);
				
				// 残高確認
				if (balance < baseBetAmount) {
					logger.error("破産...");
					System.exit(-1);
				}
			}
		}
		
		doDailyClose();
		
		writeUserStatus(ymd);
	}

	/** ベッティング */
	public RaceEx doBet(RaceEx race) throws Exception {
		List<Bet> betList = new ArrayList<>();
		
		JyoStatus jyoStatus = mapByJyo.get(race.setu.jyoCd);
		if (race.popularItemList.size() > 0) {
			int[] moneys = new int[3];
			List<OddsTItem> oddsList = OddsManager.getInstance().getRankedOddsItemList(race.setu.jyoCd, String.valueOf(race.raceInfo.no), 
					"3T", race.popularItemList.get(0).rank, race.popularItemList.get(1).rank, race.popularItemList.get(2).rank);
			
			for (OddsTItem odds : oddsList) {
				if (odds.value == 0f) {
					return race;
				}
			}
			
			// マーティン中
			if (jyoStatus.martinLoss > 0) {
				moneys = getMartinBetAmount3(oddsList.get(0).value, oddsList.get(1).value, oddsList.get(2).value, jyoStatus.martinLoss);
				race.multiplyType = RaceEx.MULTIPLY_MARTIN;
				betList.add(new Bet("3T", oddsList.get(0).value,  moneys[0], 3, oddsList.get(0).kumiban));
				betList.add(new Bet("3T", oddsList.get(1).value,  moneys[1], 3, oddsList.get(1).kumiban));
				betList.add(new Bet("3T", oddsList.get(2).value,  moneys[2], 3, oddsList.get(2).kumiban));
			} else {
				betList.add(new Bet("3T", oddsList.get(0).value,  rule.getInt("baseBetAmount"), 3, oddsList.get(0).kumiban));
				betList.add(new Bet("3T", oddsList.get(1).value,  rule.getInt("baseBetAmount"), 3, oddsList.get(1).kumiban));
				betList.add(new Bet("3T", oddsList.get(2).value,  rule.getInt("baseBetAmount"), 3, oddsList.get(2).kumiban));
				race.multiplyType = RaceEx.MULTIPLY_NORMAL;
			}
			
			race.betlist.addAll(betList);
		}
		
		return race;
	}

	/** レース結果払い戻し取得 */
	public int doResult(RaceEx race)  {
		Bet bet1 = race.betlist.get(0);
		Bet bet2 = race.betlist.get(1);
		Bet bet3 = race.betlist.get(2);
		int prize = 0;
		if (race.raceResult.sanrentanNo.equals(bet1.kumiban)) {
			prize = (int) ((float) bet1.money * ((float) race.raceResult.sanrentanPrize / (float) 100));
		} else if (race.raceResult.sanrentanNo.equals(bet2.kumiban)) {
			prize = (int) ((float) bet2.money * ((float) race.raceResult.sanrentanPrize / (float) 100));
		} else if (race.raceResult.sanrentanNo.equals(bet3.kumiban)) {
			prize = (int) ((float) bet3.money * ((float) race.raceResult.sanrentanPrize / (float) 100));
		}
		return prize;
	}
	
	protected int getMartinBetAmount(float odds, int martinLoss) throws Exception {
		double value=  (double) (((float) (martinLoss) * rule.getFloat("martinBenefitRate")) / (odds - 1.0f));
		return (int) (Math.ceil(value / 100) * 100);
	}
	
	protected int[] getMartinBetAmount3(float odds1, float odds2, float odds3, int martinLoss) throws Exception {
		int[] values = new int[3];
		double rateFactorD = (double)((odds1 / odds2) + (odds1 / odds3) + 1f);
		BigDecimal bd = new BigDecimal(String.valueOf(rateFactorD));
		BigDecimal bd2 = bd.setScale(1, RoundingMode.DOWN);
		float rateFactorF = bd2.floatValue();
		
		double value1 =  (double) (((float) (martinLoss) * rule.getFloat("martinBenefitRate")) / (odds1 - rateFactorF));
		values[0] =  (int) (Math.ceil(value1 / 100) * 100);
		
		double value2 =  (double) ((float)values[0] * (odds1 / odds2));
		values[1] =  (int) (Math.ceil(value2 / 100) * 100);
		
		double value3 =  (double) ((float)values[0] * (odds1 / odds3));
		values[2] =  (int) (Math.ceil(value3 / 100) * 100);
		
		return values;
	}

	protected RaceEx setPopularLevel(RaceEx race) throws Exception {
		Comparator<PopularItem> comparator = new PopularReverseComparator();
		List<PopularItem> piList = PopularManager.getInstance().getItems(race.setu.jyoCd, race.setu.turn,
				String.valueOf(race.raceInfo.no));
		int cutLine2 = rule.getInt("popularCutlineRank2");
		
		if (piList == null) {
			return race;
		}
		
		if (getCoherency(race.wakuList) > rule.getFloat("levelCoherencyLimit")) {
			return race;
		}
		
		String[] raceExcludeList = rule.getString("raceExcludeList").split(",");
		String strRaceNo = String.valueOf(race.raceInfo.no);
		for (int i=0; i < raceExcludeList.length; i++) {
			if (strRaceNo.equals(raceExcludeList[i])) {
				return race;
			}
		}
		
		List<PopularItem> sortItems = new ArrayList<>();
		sortItems.addAll(piList.subList(1, piList.size()));
		sortItems.sort(comparator);
		
		PopularItem target1;
		PopularItem target2;
		PopularItem target3;
		target1 = sortItems.get(0);
		target2 = sortItems.get(1);
		target3 = sortItems.get(2);
		target1.popularity = 0;
		target2.popularity = 0;
		target3.popularity = 0;
		if ((target1.percent + target2.percent + target3.percent) >= cutLine2) {
			OddsTItem odds1= OddsManager.getInstance().getRankedOddsItem(race.setu.jyoCd, 
					String.valueOf(race.raceInfo.no), "3T", target1.rank);
			OddsTItem odds2= OddsManager.getInstance().getRankedOddsItem(race.setu.jyoCd, 
					String.valueOf(race.raceInfo.no), "3T", target2.rank);
			OddsTItem odds3= OddsManager.getInstance().getRankedOddsItem(race.setu.jyoCd, 
					String.valueOf(race.raceInfo.no), "3T", target3.rank);
			if ((odds1 != null && odds2 != null && odds3 != null) && 
					(odds1.value > rule.getFloat("martinTryMinimumOdds")
							&& odds1.value < rule.getFloat("martinTryMaximumOdds"))) {
				target1.popularity = PopularItem.POPULAR;
				target2.popularity = PopularItem.POPULAR;
				target3.popularity = PopularItem.POPULAR;
				if (target1.percent >= (cutLine2 + 10)) {
					target1.popularity = PopularItem.SUPER_POPULAR;
				}
				if (target2.percent >= (cutLine2 + 10)) {
					target2.popularity = PopularItem.SUPER_POPULAR;
				}
				if (target3.percent >= (cutLine2 + 10)) {
					target3.popularity = PopularItem.SUPER_POPULAR;
				}
			}
		}
		
		if (target1.popularity >= PopularItem.POPULAR) {
			mapByJyo.get(race.setu.jyoCd).popularItemCount++;
			race.popularItemList.add(target1);
			race.popularItemList.add(target2);
			race.popularItemList.add(target3);
		}
		
		return race;
	}
	
	public static void main(String[] args) {
		try {
			// User user = new User(args[0], args[1]);
			BoatProperty.init("C:/Dev/workspace/Oxygen/pod_boatrace/test/properties/rule3T.properties");
			
			PopularManager.getInstance().load(BoatProperty.DIRECTORY_PROPERTY + "popular_3T_ip.csv", "3T");
			BettingRule rule = new BettingRule(BoatProperty.DIRECTORY_PROPERTY + "rule3T.properties");
			User3T user = new User3T("20180416", "20180505", rule);
			user.start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
