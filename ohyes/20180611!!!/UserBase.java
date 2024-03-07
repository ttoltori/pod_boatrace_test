package com.pengkong.boatrace.simulation2;

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
import com.pengkong.boatrace.model.OddsTItem;
import com.pengkong.boatrace.model.Waku;
import com.pengkong.boatrace.service.manager.OddsManager;
import com.pengkong.boatrace.simulation.model.Bet;
import com.pengkong.boatrace.simulation.model.BettingRule;
import com.pengkong.boatrace.simulation.model.PlayStatus;
import com.pengkong.boatrace.simulation.model.RaceEx;
import com.pengkong.boatrace.util.BoatUtil;
import com.pengkong.common.FileUtil;
import com.pengkong.common.MathUtil;

import lombok.Getter;
import lombok.Setter;

public abstract class UserBase {
	private Logger logger = LoggerFactory.getLogger(UserBase.class);

	protected StringBuilder sbRaceResult = new StringBuilder();
	protected StringBuilder sbJyoResult = new StringBuilder();

	protected SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
	protected SimpleDateFormat sdfSort = new SimpleDateFormat("yyyyMMddHHmmSS");

	protected List<RaceEx> raceList = new ArrayList<>();

	protected BettingRule rule;

	/** ベッティング単位金額 */
	protected int baseBetAmount = 1000;
	
	/** 総ベッティング金額 */
	protected int totalBetAmount = 0;
	
	/** 的中数 */
	protected int hitCount = 0;

	/** 総払い戻し金額 */
	public int totalPrizeAmount = 0;

	boolean isMartin = false;

	@Getter
	@Setter
	protected int balance = 0;
	protected int dailyStartBalance = 0;
	protected int jyoCount = 0;
	protected int betCount = 0;

	int martinDailySuccessCount =0;
	int martinDailyFailCount = 0;
	int status = PlayStatus.STATUS_OPEN;
	
	protected String fromYmd;
	protected String toYmd;

	public UserBase() {
		super();
	}

	public abstract int getMartinCount();
	
	public abstract int getMartinBetAmoutAll();
	
	public abstract void doDailyBet(String yyyyMMdd) throws Exception;

	public void start()  {
		try {
			
			// 総残高
			balance = rule.getInt("totalStartBalance");

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
		HashMap<String, String> jyoCdMap = new HashMap<>();
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
			if (!jyoCdMap.containsKey(race.setu.jyoCd)) {
				jyoCdMap.put(race.setu.jyoCd, race.setu.jyoCd);
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

	protected void writeRaceInformation(RaceEx race) throws Exception {
		sbRaceResult = new StringBuilder();
		sbRaceResult.append(sdfSort.format(new Date()));
		sbRaceResult.append(",");
		sbRaceResult.append(race.raceInfo.ymd);
		sbRaceResult.append(",");
		sbRaceResult.append(race.setu.jyoCd);
		sbRaceResult.append(",");
		sbRaceResult.append(race.setu.jyo);
		sbRaceResult.append(",");
		sbRaceResult.append(race.setu.turn);
		sbRaceResult.append(",");
		sbRaceResult.append(race.setu.grade);
		sbRaceResult.append(",");
		sbRaceResult.append(getMartinCount());
		sbRaceResult.append(",");
		//sbRaceResult.append(jyoStatus.martinLoss);
		sbRaceResult.append(",");
		if (martinDailySuccessCount > 0) {
			sbRaceResult.append(martinDailySuccessCount);
		}
		sbRaceResult.append(",");
		if (martinDailyFailCount > 0) {
			sbRaceResult.append(martinDailyFailCount);
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
		} else if (rule.getString("type").equals("3F")) {
			sbRaceResult.append(race.raceResult.sanrenhukuNo + "/" 
					+ (float)race.raceResult.sanrenhukuPrize / 100f + "/" + race.raceResult.sanrenhukuPopular);    
		} else if (rule.getString("type").equals("2T")) {
			sbRaceResult.append(race.raceResult.nirentanNo + "/" 
					+ (float)race.raceResult.nirentanPrize / 100f + "/" + race.raceResult.nirentanPopular);    
		} else if (rule.getString("type").equals("2F")) {
			sbRaceResult.append(race.raceResult.nirenhukuNo + "/" 
					+ (float)race.raceResult.nirenhukuPrize / 100f + "/" + race.raceResult.nirenhukuPopular);    
		} else if (rule.getString("type").equals("1T")) {
			sbRaceResult.append(race.raceResult.tansyoNo + "/" 
					+ (float)race.raceResult.tansyoPrize / 100f + "/" + race.raceResult.tansyoPopular);    
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
				sbRaceResult.append(race.skip);
			}
		}
		sbRaceResult.append(",");
		sbRaceResult.append(race.prize);

		sbRaceResult.append(",");
		sbRaceResult.append(getLevelPattern(race));
		sbRaceResult.append(",");
		sbRaceResult.append(getMartinBetAmoutAll());

		// sbRaceResult.append(System.lineSeparator());
		if (sbRaceResult.length() > 0) {
			String filepath = BoatProperty.DIRECTORY_RESULT + "race_" + fromYmd + "_" + toYmd + ".csv";
			FileUtil.appendFileByLine(filepath, sbRaceResult.toString());
		}
		//logger.info("レース終了," + sbRaceResult.toString());
	}
	
	protected String getLevelPattern(RaceEx race) {
		StringBuilder sb = new StringBuilder();
		for (Waku waku : race.wakuList) {
			sb.append(waku.level.substring(0, 1));
		}
		return sb.toString();
	}

	protected String getResultKumiban(RaceEx race) throws Exception {
		String ret = null;
		String type = rule.getString("type");
		if (type.equals("3T")) {
			ret = race.raceResult.sanrentanNo;
		} else if (type.equals("3F")) {
			ret = race.raceResult.sanrenhukuNo;
		} else if (type.equals("2T")) {
			ret = race.raceResult.nirentanNo;
		} else if (type.equals("2F")) {
			ret = race.raceResult.nirenhukuNo;
		} else if (type.equals("1T")) {
			ret = race.raceResult.tansyoNo;
		} 
		return ret;
	}

	protected int getResultPrize(RaceEx race) throws Exception {
		int ret = -1;
		String type = rule.getString("type");
		if (type.equals("3T")) {
			ret = race.raceResult.sanrentanPrize;
		} else if (type.equals("3F")) {
			ret = race.raceResult.sanrenhukuPrize;
		} else if (type.equals("2T")) {
			ret = race.raceResult.nirentanPrize;
		} else if (type.equals("2F")) {
			ret = race.raceResult.nirenhukuPrize;
		} else if (type.equals("1T")) {
			ret = race.raceResult.tansyoPrize;
		} 
		return ret;
	}

	protected void doDailyClose() {
	}

	protected int getHitRate() {
		if (totalBetAmount == 0) {
			return 0;
		}
		return (int)(((float)hitCount / (float)betCount) * 100f);
	}

	protected int getBenefitRate() {
		if (totalPrizeAmount == 0) {
			return 0;
		}
		return (int) (((float) totalPrizeAmount) / (float) totalBetAmount * 100f);
	}
}
