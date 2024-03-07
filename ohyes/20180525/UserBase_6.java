package com.pengkong.boatrace.simulation;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.pengkong.boatrace.common.BoatProperty;
import com.pengkong.boatrace.exception.RaceSkipException;
import com.pengkong.boatrace.model.Waku;
import com.pengkong.boatrace.service.manager.JyoManager;
import com.pengkong.boatrace.util.BoatUtil;
import com.pengkong.common.FileUtil;

import lombok.Getter;
import lombok.Setter;

public abstract class UserBase_6 {
	private Logger logger = LoggerFactory.getLogger(UserBase_6.class);

	protected StringBuilder sbRaceResult = new StringBuilder();
	protected StringBuilder sbJyoResult = new StringBuilder();

	protected SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
	protected SimpleDateFormat sdfSort = new SimpleDateFormat("yyyyMMddHHmmSS");

	protected HashMap<String, JyoStatus> mapByJyo = new HashMap<>();

	protected List<RaceEx> raceList = new ArrayList<>();

	protected BettingRule rule;

	/** ベッティング単位金額 */
	protected int baseBetAmount = 1000;
	/**
	 * 現在のマーティン適用中の場 （ユーザー単位マーティン継続の場合のみ有効 ）
	 */
	protected JyoStatus currentMartinJyo;

	@Getter
	@Setter
	protected int balance = 0;
	protected int dailyStartBalance = 0;
	protected int jyoCount = 0;
	protected int betCount = 0;

	MartinCalculator_6 martinCalculator = null;
	int martinDailySuccessCount =0;
	int martinDailyFailCount = 0;
	int status = JyoStatus.STATUS_OPEN;
	
	protected String fromYmd;
	protected String toYmd;

	public UserBase_6() {
		super();
	}

	public abstract void doDailyBet(String yyyyMMdd) throws Exception;

	public void start()  {
		try {
			martinCalculator = new MartinCalculator_6(rule);
			
			// 総残高
			balance = rule.getInt("totalStartBalance");
			// 全体場設定
			for (int i = 0; i < 24; i++) {
				JyoStatus jyoStatus = new JyoStatus();
				String jyoCd = String.format("%02d", i + 1);
				jyoStatus.jyoCd = jyoCd;
				jyoStatus.jyoName = JyoManager.getJyoName(jyoCd);
				mapByJyo.put(jyoCd, jyoStatus);
			}

			Calendar calendar = Calendar.getInstance();
			calendar.setTime(sdf.parse(fromYmd));
			Date currDate = calendar.getTime();
			Date toDate = sdf.parse(toYmd);
			while (currDate.compareTo(toDate) <= 0) {
				String yyyyMMdd = sdf.format(currDate);
				dailyStartBalance = balance;
				doDailyBet(yyyyMMdd);
				dailyStartBalance = 0;
				// 1日増加
				calendar.add(Calendar.DATE, 1);
				currDate = calendar.getTime();
			}
		} catch (Exception e) {
			logger.error("profram failed!!! ", e);
			e.printStackTrace();
		}
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
			if (race.popularItemList.size() <= 0) {
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
	
	abstract protected RaceEx setPopularLevel(RaceEx race) throws Exception;

	protected boolean isJyoAllowed(String jyoCd, String jyoLevel) throws Exception {
		return (rule.getString("jyoIncludeList").contains(jyoCd)
				&& rule.getString("jyoIncludeLevels").contains(jyoLevel));
	}

	/** レース結果チェックのためにレースのソート基準時間を１５分後に設定する */
	protected RaceEx setSortTime(RaceEx race) throws RaceSkipException {
		try {
			String ymdHmS = race.raceInfo.ymd + String.format("%04d00", race.raceInfo.sime);
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(sdfSort.parse(ymdHmS));
			Date currDate = calendar.getTime();
			// 15分後
			calendar.add(Calendar.MINUTE, 15);
			currDate = calendar.getTime();
			ymdHmS = sdfSort.format(currDate);
			race.sortTime = Integer.parseInt(ymdHmS.substring(8, 14));
		} catch (Exception e) {
			throw new RaceSkipException("レースソート時間設定失敗.");
		}

		return race;
	}

	protected void setDefaultJyoInfo(JyoStatus jyoStatus, RaceEx race) {
		jyoStatus.yyyyMMdd = race.raceInfo.ymd;
		jyoStatus.setuTurn = race.setu.turn;
		jyoStatus.grade = race.setu.grade;
	}

	protected void writeUserStatus(String ymd) throws Exception {
		StringBuilder sb = new StringBuilder();
		sb.append(sdfSort.format(new Date()));
		sb.append(",");
		sb.append(ymd);
		sb.append(",");
		sb.append(rule.ruleName);
		sb.append(",");
		sb.append(jyoCount);
		sb.append(",");
		sb.append(betCount);
		sb.append(",");
		sb.append(balance - dailyStartBalance);
		sb.append(",");
		sb.append(balance);
		String line = sb.toString();

		String filepath = BoatProperty.DIRECTORY_RESULT + "user_" + fromYmd + "_" + toYmd + ".csv";
		FileUtil.appendFileByLine(filepath, line);

		logger.info("総括," + sb.toString());
	}

	protected void writeRaceInformation(JyoStatus jyoStatus, RaceEx race) throws Exception {
		sbRaceResult = new StringBuilder();
		sbRaceResult.append(sdfSort.format(new Date()));
		sbRaceResult.append(",");
		sbRaceResult.append(jyoStatus.yyyyMMdd);
		sbRaceResult.append(",");
		sbRaceResult.append(jyoStatus.jyoCd);
		sbRaceResult.append(",");
		sbRaceResult.append(jyoStatus.jyoName);
		sbRaceResult.append(",");
		sbRaceResult.append(jyoStatus.setuTurn);
		sbRaceResult.append(",");
		sbRaceResult.append(jyoStatus.grade);
		sbRaceResult.append(",");
		sbRaceResult.append(martinCalculator.getMartinCount());
		sbRaceResult.append(",");
		sbRaceResult.append(jyoStatus.martinLoss);
		sbRaceResult.append(",");
		if (jyoStatus.martinDailySuccessCount > 0) {
			sbRaceResult.append("SC");
			jyoStatus.martinDailySuccessCount = 0;
		}
		sbRaceResult.append(",");
		if (jyoStatus.martinDailyFailCount > 0) {
			sbRaceResult.append("FL");
			jyoStatus.martinDailyFailCount = 0;
		}
		sbRaceResult.append(",");
		
		sbRaceResult.append(balance);
		sbRaceResult.append(",");
		sbRaceResult.append(race.raceInfo.no);
		sbRaceResult.append(",");
		if (race.popularItem != null) {
			sbRaceResult.append(race.popularItem.popularity);
		}
		sbRaceResult.append(",");
		
		// ベッティング内容
		if (race.betlist.size() > 0) {
			for (Bet bet : race.betlist) {
				sbRaceResult.append(bet.toString());	
			}
		}
		sbRaceResult.append(",");
		
		if (rule.getString("type").equals("3T")) {
			sbRaceResult.append(race.raceResult.sanrentanNo + "/" 
					+ (float)race.raceResult.sanrentanPrize / 100f + "/" + race.raceResult.sanrentanPopular);    
		} else if (rule.getString("type").equals("2T")) {
			sbRaceResult.append(race.raceResult.nirentanNo + "/" 
					+ (float)race.raceResult.nirentanPrize / 100f + "/" + race.raceResult.nirentanPopular);    
		}
		sbRaceResult.append(",");
		
		sbRaceResult.append(race.multiplyType);
		sbRaceResult.append(",");
		if (race.betlist.size() > 0) {
			sbRaceResult.append(race.getBetMoney());
		} else {
			sbRaceResult.append(0);
		}
		sbRaceResult.append(",");

		if (race.prize > 0) {
			sbRaceResult.append("Y");
		} else {
			if (race.betlist.size() > 0) {
				sbRaceResult.append("N");
			} else {
				sbRaceResult.append("S");
			}
		}
		sbRaceResult.append(",");
		sbRaceResult.append(race.prize);

		sbRaceResult.append(",");
		sbRaceResult.append(getLevelPattern(race));

		// sbRaceResult.append(System.lineSeparator());
		if (sbRaceResult.length() > 0) {
			String filepath = BoatProperty.DIRECTORY_RESULT + "race_" + fromYmd + "_" + toYmd + ".csv";
			FileUtil.appendFileByLine(filepath, sbRaceResult.toString());
		}
		//logger.info("レース終了," + sbRaceResult.toString());

		// 場状態更新
		jyoStatus.remainingRaceCount--;
		// 場内全レース終了 or 破産 or マーティリセット回数制限
		if (jyoStatus.status == JyoStatus.STATUS_BANKRUPT
				|| jyoStatus.status == JyoStatus.STATUS_MARTIN_RESET_RESTRICT 
				|| jyoStatus.status == JyoStatus.STATUS_MARTIN_AMOUNT_RESTRICT) {

			// マーティン法は日毎にクリアする
			if (rule.getString("martinDailyClear").equals("Y")) {
				jyoStatus.martinCount = 0;
				jyoStatus.martinLoss = 0;
			}

			jyoStatus.clear();
		}
	}
	
	protected String getLevelPattern(RaceEx race) {
		StringBuilder sb = new StringBuilder();
		for (Waku waku : race.wakuList) {
			sb.append(waku.level.substring(0, 1));
		}
		return sb.toString();
	}

	public void doDailyClose() {
		for (JyoStatus jyoStatus : mapByJyo.values()) {
			jyoStatus.clear();
		}
	}
	
}
