package com.pengkong.boatrace.simulation;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.pengkong.boatrace.common.BoatProperty;
import com.pengkong.boatrace.model.PopularItem;
import com.pengkong.boatrace.model.Waku;
import com.pengkong.boatrace.service.manager.OddsManager;

public class User_12 extends UserBase_11 {
	private Logger logger = LoggerFactory.getLogger(User_12.class);
	
	int bettingSortTime;
	MartinCalculator_12 martinCalculator = null;
	boolean isMartin = false;

	public User_12(String fromYmd, String toYmd, BettingRule rule) throws Exception{
		super();
		this.fromYmd = fromYmd;
		this.toYmd = toYmd;
		this.rule = rule;
		martinCalculator = new MartinCalculator_12(rule);
	}
	
	@Override
	public int getMartinCount() {
		return martinCalculator.getBetAmountTotal();
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
				//bettingSortTime = race.sortTime;
				
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
			
			if (race.multiplyType == RaceEx.MULTIPLY_UNDER_MINIMUM) {
				race = createAndSetBetList(race);
			}
		} else {
			race = createAndSetBetList(race);
		}
		return race;
	}

	protected RaceEx createAndSetBetList(RaceEx race) throws Exception{
		String[] kumibanList = rule.getString("kumibanNormalList").split(",");
		String[] betAmountList =  rule.getString("baseBetAmountList").split(",");
		for (int i = 0; i < kumibanList.length; i++) {
			String kumiban = kumibanList[i];
			
			// ｵｯｽﾞデータ存在以前の場合
			if (Integer.parseInt(race.raceInfo.ymd) < 20170309) {
				Bet bet = new Bet(rule.getString("type"), -1, Integer.parseInt(betAmountList[i]), 0, kumiban);
				race.betlist.add(bet);
				continue;
			}
			
			Float odds = OddsManager.getInstance().getOddsValue(race.setu.jyoCd, String.valueOf(race.raceInfo.no), rule.getString("type"), kumiban);
			if (odds < rule.getFloat("minimumOdds")) {
				race.betlist.clear();
				return race;
			} else {
				Bet bet = new Bet(rule.getString("type"), odds, Integer.parseInt(betAmountList[i]), 0, kumiban);
				race.betlist.add(bet);
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
		
		Waku waku1 = race.wakuList.get(0);
		Waku waku2 = race.wakuList.get(1);
		Waku waku3 = race.wakuList.get(2);
		Waku waku4 = race.wakuList.get(3);
		if (
				( waku2.nationWiningRate > 6 )
				//&& ( waku2.nationWiningRate > 5 )
				 && ( waku3.nationWiningRate > 6 && waku4.nationWiningRate > 6)
				//&& (race.setu.timezone.equals("N"))
			) {
			race.popularItemList.add(new PopularItem(null, 0, 0));
		}
		
		
		return race;
	}
	
	public static void main(String[] args) {
		try {
			// User user = new User(args[0], args[1]);
			BoatProperty.init("C:/Dev/workspace/Oxygen/pod_boatrace/test/properties/rule_12.properties");
			BettingRule rule = new BettingRule(BoatProperty.DIRECTORY_PROPERTY + "rule_12.properties");
			User_12 user = new User_12("20150101", "20180430", rule);
			user.start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
