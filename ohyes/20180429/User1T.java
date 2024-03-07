package com.pengkong.boatrace.simulation;

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

public class User1T extends UserBase {
	private Logger logger = LoggerFactory.getLogger(User1T.class);

	int popularItemCount = 0;
	
	public User1T(String fromYmd, String toYmd, BettingRule rule) {
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
		// 場別残高振り分け
		distributeJyoBalance();
		
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

				int betMoney = race.betlist.get(0).money;
				// 場残高確認
				if ((jyoStatus.balance - betMoney) <= 0) {
					jyoStatus.balance = rule.getInt("jyoStartBalance");
					balance -= jyoStatus.balance;
				}

				// 残高更新
				jyoStatus.totalBetAmount += betMoney;
				jyoStatus.betCount++;
				jyoStatus.balance -= betMoney;
				if (race.multiplyType == RaceEx.MULTIPLY_MARTIN) {
					jyoStatus.martinCount++;
					jyoStatus.martinLoss += betMoney;
				}

				// 結果確認用再スケジューリング
				race = setSortTime(race);
				race.status = RaceEx.STATUS_BETTING;
				raceList.sort((RaceEx r1, RaceEx r2) -> r1.sortTime - r2.sortTime);
				// 再スタート
				i = 0;

			} else if (race.status == RaceEx.STATUS_BETTING) {
				try {
					// 払戻取得
					race.prize = doResult(race);
				} catch (Exception e) {
					jyoStatus.skipCount++;
					race.skip = "エラー";
					race.status = RaceEx.STATUS_CLOSED;
					writeRaceInformation(jyoStatus, race);
					continue;
				}
				if (race.setu.jyoCd.equals("01")){
					System.out.println("");
				}

				// 残高更新
				if (race.prize > 0) {
					// 払戻あり
					jyoStatus.hitCount++;
					jyoStatus.totalPrizeAmount += race.prize;
					jyoStatus.balance += race.prize;
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
							if (jyoStatus.popularItemCount < rule.getInt("martinRestrictRemainPopularItem")) {
								// マーティ法回数制限による直中止判定
								jyoStatus.status = JyoStatus.STATUS_MARTIN_RESET_RESTRICT;
							}
						}
					}
				} else {
					if (race.multiplyType == RaceEx.MULTIPLY_MARTIN) {
						if (jyoStatus.martinLoss > rule.getInt("martinLossLimit")) {
							jyoStatus.martinCount = 0;
							jyoStatus.martinLoss = 0;
							jyoStatus.martinDailyFailCount++;
//							// マーティ法最大金額超過
//							jyoStatus.status = JyoStatus.STATUS_MARTIN_AMOUNT_RESTRICT;
						}
					} else {
						jyoStatus.martinLoss = race.betlist.get(0).money;
					}
					jyoStatus.lossAmount += race.betlist.get(0).money;
					jyoStatus.totalLossAmount += race.betlist.get(0).money;
				}

				// 場残高確認
				if (jyoStatus.balance < baseBetAmount) {
					jyoStatus.status = JyoStatus.STATUS_BANKRUPT;
					writeRaceInformation(jyoStatus, race);
					continue;
				}

				race.status = RaceEx.STATUS_CLOSED;
				writeRaceInformation(jyoStatus, race);
			}
		}
		writeUserStatus(ymd);
	}

	/** ベッティング */
	public RaceEx doBet(RaceEx race) throws Exception {
		Bet bet = null;
		JyoStatus jyoStatus = mapByJyo.get(race.setu.jyoCd);
		if (race.popularItem != null) {
			if (race.setu.jyoCd.equals("01") && race.raceInfo.no == 1 && race.raceInfo.ymd.equals("20170321")) {
				System.out.println("");
			}
			int money = 0;
			OddsTItem odds = OddsManager.getInstance().getRankedOddsItem(race.setu.jyoCd, String.valueOf(race.raceInfo.no), 
					"1T", race.popularItem.rank);
			// TODO
			if (odds.value == 0f) {
				return race;
			}
			
			// マーティン中
			if (jyoStatus.martinLoss > 0) {
				money = getMartinBetAmount(odds.value, jyoStatus.martinLoss);
				bet = new Bet("1T", odds.value,  money, 2, odds.kumiban);
				race.multiplyType = RaceEx.MULTIPLY_MARTIN;
			} else {
				bet = new Bet("1T", odds.value,  rule.getInt("baseBetAmount"), 2, odds.kumiban);
			}
			
			race.betlist.add(bet);
		}
		
		return race;
	}

	protected int getMartinBetAmount(float odds, int martinLoss) throws Exception {
		double value=  (double) (((float) (martinLoss) * rule.getFloat("martinBenefitRate")) / (odds - 1.0f));
		return (int) (Math.ceil(value / 100) * 100);
	}

	protected void loadRaces(String ymd) throws Exception {
		raceList = new ArrayList<>();
 		jyoCount = 0;
		String filepath = BoatProperty.DIRECTORY_CSV + "race_" + ymd + ".csv";
		List<String> lines = FileUtil.readFileByLineArr(filepath, "UTF8");
		for (String csvLine : lines) {
			RaceEx race = BoatUtil.convertRaceEx(csvLine);
			// 対象外場は外す
			if (!isJyoAllowed(race.setu.jyoCd, race.setu.grade)) {
				continue;
			}
			race = setPopularLevel(race);
			if (race.popularItem == null) {
				continue;
			}
			
			raceList.add(race);
			JyoStatus jyoStatus;
			jyoStatus = mapByJyo.get(race.setu.jyoCd);
			jyoStatus.remainingRaceCount++;
			if (jyoStatus.status != JyoStatus.STATUS_OPEN) {
				setDefaultJyoInfo(jyoStatus, race);
				jyoStatus.status = JyoStatus.STATUS_OPEN;
				jyoCount++;
			}
		}
	}
	protected RaceEx setPopularLevel(RaceEx race) throws Exception {
		if (race.setu.jyoCd.equals("01") && race.raceInfo.ymd.equals("20170409")) {
			System.out.println("");
		}
		Comparator<PopularItem> comparator = new PopularReverseComparator();
		List<PopularItem> piList = PopularManager.getInstance().getItems(race.setu.jyoCd, race.setu.turn,
				String.valueOf(race.raceInfo.no));
		int cutLine2 = rule.getInt("popularCutlineRank2");
		
		if (piList == null) {
			return race;
		}
		
		List<PopularItem> sortItems = new ArrayList<>();
		sortItems.addAll(piList.subList(1, piList.size()));
		sortItems.sort(comparator);
		
		PopularItem target;
		target = sortItems.get(0);
		target.popularity = 0;
		if (target.percent >= cutLine2) {
			OddsTItem odds = OddsManager.getInstance().getRankedOddsItem(race.setu.jyoCd, 
					String.valueOf(race.raceInfo.no), "1T", target.rank);
			if (odds != null && 
					(odds.value > rule.getFloat("martinTryMinimumOdds")
							&& odds.value < rule.getFloat("martinTryMaximumOdds"))) {
				target.popularity = PopularItem.POPULAR;
				if (target.percent >= (cutLine2 + 10)) {
					target.popularity = PopularItem.SUPER_POPULAR;
				}
			}
		}
		
		if (target.popularity >= PopularItem.POPULAR) {
			mapByJyo.get(race.setu.jyoCd).popularItemCount++;
			race.popularItem = target;
		}
		
		return race;
	}
	
	/** レース結果払い戻し取得 */
	public int doResult(RaceEx race)  {
		Bet bet = race.betlist.get(0);
		int prize = 0;
		if (race.raceResult.tansyoNo.equals(bet.kumiban)) {
			prize = (int) ((float) bet.money * ((float) race.raceResult.tansyoPrize / (float) 100));
		}
		return prize;
	}


	private void distributeJyoBalance() throws Exception {
		int jyoBalance = rule.getInt("jyoStartBalance");
		baseBetAmount = rule.getInt("baseBetAmount");
		// 予算金額不足
		if ((jyoBalance * jyoCount) > balance) {
			writeRaceReport();
			// 完全破産
			logger.error("総破産");
			System.exit(-1);
		}

		for (JyoStatus jyoStatus : mapByJyo.values()) {
			if (jyoStatus.status == JyoStatus.STATUS_OPEN) {
				jyoStatus.balance = jyoBalance;
				balance -= jyoBalance;
			}
		}
	}

	public static void main(String[] args) {
		try {
			// User user = new User(args[0], args[1]);
			PopularManager.getInstance().load("C:/Dev/workspace/Oxygen/pod_boatrace/release/properties/popular_1T_ip.csv", "1T");
			BettingRule rule = new BettingRule(
					"C:/Dev/workspace/Oxygen/pod_boatrace/release/properties/rule2.properties");
			User1T user = new User1T("20170320", "20170519", rule);
			user.start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
