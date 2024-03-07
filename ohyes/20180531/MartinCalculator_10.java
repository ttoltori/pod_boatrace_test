package com.pengkong.boatrace.simulation;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

import com.pengkong.boatrace.model.OddsTItem;
import com.pengkong.boatrace.service.manager.OddsManager;

import lombok.Getter;
import lombok.Setter;

public class MartinCalculator_10 {
	
	@Getter
	private List<Integer> amountList = new ArrayList<>();
	
	@Getter
	@Setter
	private int betAmountTotal = 0;
	
	private BettingRule rule;
	
	public MartinCalculator_10(BettingRule rule) throws Exception{
		this.rule = rule;
	}
	
	public int getMartinCount() {
		return amountList.size();
	}

	public void clear() {
		amountList = new ArrayList<>();
		betAmountTotal = 0;
	}
	
	public RaceEx createAndSetBetList(RaceEx race, int remainBalance) throws Exception {
		List<Bet> betList = new ArrayList<>();
		List<Float> oddsList = new ArrayList<>();
		

		int martinBetCountMax = rule.getInt("martinBetCountMax");
		int martinBetCount = 0;
		List<OddsTItem> oddsItemList = OddsManager.getInstance().getOddsItemList(race.setu.jyoCd, String.valueOf(race.raceInfo.no), rule.getString("type"));
		String[] kumiban = new String[martinBetCountMax];
		int kumibanIdx = 0;
		for (int i = 0; i < rule.getInt("oddsRankListMartinMax"); i++) {
			Float odds = oddsItemList.get(i).value;
			if (odds == null || odds < rule.getFloat("minimunMartinOdds")) {
				continue;
			} else {
				kumiban[kumibanIdx++] = oddsItemList.get(i).kumiban;
				oddsList.add(odds);
				martinBetCount++;
				if (martinBetCount >= martinBetCountMax) {
					break;
				}
			}
		}
		
		if (oddsList.size() < martinBetCountMax) {
			race.multiplyType = RaceEx.MULTIPLY_UNER_MINIMUM;
			return race;
		}
		
		Float[] arrOdds = new Float[oddsList.size()];
		oddsList.toArray(arrOdds);
		int[] moneys = getMartinBetAmountList(betAmountTotal, arrOdds);
		
		int betAmountRace = 0;
		for (int i=0; i < moneys.length; i++) {
			Bet bet = new Bet(rule.getString("type"), arrOdds[i], moneys[i], 0, kumiban[i]);
			//Bet bet = new Bet(rule.getString("type"), arrOdds[i], moneys[i], 0, kumibanList[i]);
			betList.add(bet);
			
			betAmountRace += moneys[i];
		}
		
		// ベッティング金額超過ならレーススキップ
//		if (betAmountRace > (rule.getInt("maximumBetAmount") + remainBalance)) {
		if (betAmountRace > (rule.getInt("maximumBetAmount") )) {
			race.multiplyType = RaceEx.MULTIPLY_RECOVERY;
			return race;
		}
		
		amountList.add(Integer.valueOf(betAmountRace));
		betAmountTotal += betAmountRace;
		race.multiplyType = RaceEx.MULTIPLY_MARTIN;
		race.betlist = betList;
		
		return race;
	}
	
	protected int[] getMartinBetAmountList(int martinLoss, Float ...oddsList) throws Exception {
		int[] values = new int[oddsList.length];
		
		double sumOddsFactor = 0;
		for (int i=1; i < oddsList.length; i++) {
			sumOddsFactor += (double)(oddsList[0] / oddsList[i]);
		}
		double rateFactorD = sumOddsFactor + 1;
		
		BigDecimal bd = new BigDecimal(String.valueOf(rateFactorD));
		BigDecimal bd2 = bd.setScale(1, RoundingMode.DOWN);
		float rateFactorF = bd2.floatValue();
		
		double value1 =  (double) (((float) (martinLoss) * rule.getFloat("martinBenefitRate")) / (oddsList[0] - rateFactorF));
		values[0] =  (int) (Math.ceil(value1 / 100) * 100);

		double dValue;
		for (int i = 1; i < oddsList.length; i++) {
			dValue = (double) ((float)values[0] * (oddsList[0] / oddsList[i]));
			values[i] = (int) (Math.ceil(dValue / 100) * 100);
		}
		
		return values;
	}
	
	public static void main(String[] args) {
		System.out.println(  Math.ceil((double)1.4f));
		System.out.println(  Math.ceil((double)1.5f));
		System.out.println(  Math.ceil((double)1.6f));
	}

}
