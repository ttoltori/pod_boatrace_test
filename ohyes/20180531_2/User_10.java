package com.pengkong.boatrace.simulation;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.pengkong.boatrace.common.BoatProperty;
import com.pengkong.boatrace.model.OddsTItem;
import com.pengkong.boatrace.model.PopularItem;
import com.pengkong.boatrace.service.manager.OddsManager;

public class User_10 extends UserBase_10 {
	private Logger logger = LoggerFactory.getLogger(User_10.class);
	
	int bettingSortTime;
	boolean isMartin = false;

	public User_10(String fromYmd, String toYmd, BettingRule rule) {
		super();
		this.fromYmd = fromYmd;
		this.toYmd = toYmd;
		this.rule = rule;
	}

	@Override
	public void doDailyBet(String ymd) throws Exception {
		bettingSortTime = 0;
		martinDailySuccessCount = 0;
		martinDailyFailCount = 0;
		status = JyoStatus.STATUS_OPEN;
		
		OddsManager.getInstance().load(ymd);
		
		loadRaces(ymd);

		if (jyoCount <= 0) {
			return;
		}
		betCount = 0;
		
		// 締切時間でソート
		raceList.sort((RaceEx r1, RaceEx r2) -> r1.sortTime - r2.sortTime);
		int i = 0;
		// for (i = 0; i < raceList.size(); i++) {
		while (i < raceList.size()) {
			if (status != JyoStatus.STATUS_OPEN) {
				break;
			}
			
			RaceEx race = raceList.get(i);
			i++;

			JyoStatus jyoStatus = mapByJyo.get(race.setu.jyoCd);

			if (race.status == RaceEx.STATUS_CLOSED) {
				continue;
			} else if (race.status == RaceEx.STATUS_WAIT) {
				// 既存ベッティングあり
				if (race.sortTime <= bettingSortTime) {
					race.status = RaceEx.STATUS_CLOSED;
					continue;
				}
				
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

				if (race.multiplyType == RaceEx.MULTIPLY_RECOVERY) {
					martinCalculator.clear();
					isMartin = false;
					jyoStatus.status = JyoStatus.STATUS_MARTIN_RESET_RESTRICT;
					status = JyoStatus.STATUS_MARTIN_RESET_RESTRICT;
				}

				// ベッティングなし
				if (race.betlist.size() == 0) {
					jyoStatus.skipCount++;
					race.skip = "スキップ";
					race.status = RaceEx.STATUS_CLOSED;
					writeRaceInformation(jyoStatus, race);
					break;
					//continue;
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

				// 結果確認用再スケジューリング
				race = setSortTime(race);
				bettingSortTime = race.sortTime;
				
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
						martinDailySuccessCount++;
						martinCalculator.clear();
						isMartin = false;
						
						if (martinDailySuccessCount > rule.getInt("martinSuccessRepeatLimit")) {
							// マーティ法回数制限による直中止判定
							jyoStatus.status = JyoStatus.STATUS_MARTIN_RESET_RESTRICT;
							status = JyoStatus.STATUS_MARTIN_RESET_RESTRICT;
						} else {
							// nothing to do
						}
					}
				} else {
					if (race.multiplyType == RaceEx.MULTIPLY_MARTIN) {
						if (martinCalculator.getMartinCount() >= rule.getInt("martinCountLimit")) {
							// マーティ法最大金額超過
							//jyoStatus.status = JyoStatus.STATUS_MARTIN_AMOUNT_RESTRICT;
							//status = JyoStatus.STATUS_MARTIN_AMOUNT_RESTRICT;
							martinCalculator.clear();
							isMartin = false;
						}
					} else {
						martinCalculator.setBetAmountTotal(martinCalculator.getBetAmountTotal() + race.getBetMoney());
						isMartin = true;
					}
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
		if (isMartin && rule.getInt("martinCountLimit") > 0) {
			race = martinCalculator.createAndSetBetList(race, balance - rule.getInt("totalStartBalance"));
			
			if (race.multiplyType == RaceEx.MULTIPLY_UNER_MINIMUM) {
				race = createAndSetBetList(race);
			}
		} else {
			race = createAndSetBetList(race);
		}
		return race;
	}

	protected RaceEx createAndSetBetList(RaceEx race) throws Exception{
//		String[] oddsRankList = rule.getString("oddsRankList").split(",");
//		for (String oddsRank : oddsRankList) {
		String[] kumibanList = rule.getString("kumibanNormal").split(",");
		for (String kumiban : kumibanList) {
			String[] oddsRankList = rule.getString("oddsRankListNormal").split(",");
			for (int i=0; i < oddsRankList.length; i++) {
				OddsTItem oddsItem = OddsManager.getInstance().getRankedOddsItem(race.setu.jyoCd, String.valueOf(race.raceInfo.no), rule.getString("type"), Integer.parseInt(oddsRankList[i]));
				if (oddsItem.kumiban.equals(kumiban)) {
					Bet bet = new Bet(rule.getString("type"), oddsItem.value, rule.getInt("baseBetAmount"), 0, oddsItem.kumiban);
					race.betlist.add(bet);
				} else {
//					race.betlist.clear();
//					return race;
				}
			}
		}
		
		race.multiplyType = RaceEx.MULTIPLY_NORMAL;
		return race;
	}
	
	/** レース結果払い戻し取得 */
	public int doResult(RaceEx race) throws Exception {
		int prize = 0;
		for (Bet bet : race.betlist) {
			if (getResultKumiban(race).equals(bet.kumiban)) { 
				prize = (int) ((float) bet.money * ((float) getResultPrize(race) / (float) 100));
				break;
			}
		}
		
		return prize;
	}
	
	protected RaceEx setPopularLevel(RaceEx race) throws Exception {
		String[] raceExcludeList = rule.getString("raceExcludeList").split(",");
		String strRaceNo = String.valueOf(race.raceInfo.no);
		for (int i=0; i < raceExcludeList.length; i++) {
			if (strRaceNo.equals(raceExcludeList[i])) {
				return race;
			}
		}
//		if ((race.wakuList.get(rule.getInt("mainWakuIndex")).nationWiningRate > rule.getFloat("mainWakuWinningRateMinimum"))
		if ((race.wakuList.get(rule.getInt("mainWakuIndex")).motor2WiningRate > rule.getFloat("mainWakuMotor2WinningRateMinimum"))
				&& (race.wakuList.get(rule.getInt("mainWakuIndex")).nationWiningRate > rule.getFloat("mainWakuWinningRateMinimum"))
				) {
			race.popularItemList.add(new PopularItem(null, 0, 0));
		}
		
		return race;
	}
	
	public static void main(String[] args) {
		try {
			// User user = new User(args[0], args[1]);
			BoatProperty.init("C:/Dev/workspace/Oxygen/pod_boatrace/test/properties/rule_10.properties");
			BettingRule rule = new BettingRule(BoatProperty.DIRECTORY_PROPERTY + "rule_10.properties");
			User_10 user = new User_10("20170309", "20180430", rule);
			user.start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
