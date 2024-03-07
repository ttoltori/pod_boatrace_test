package com.pengkong.boatrace.simulation;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

import com.pengkong.boatrace.model.OddsTItem;
import com.pengkong.boatrace.model.comparator.OddsTItemValueComparator;
import com.pengkong.boatrace.service.manager.OddsManager;

import lombok.Getter;
import lombok.Setter;

public class MartinCalculator_11 {
	
	@Getter
	private List<Integer> amountList = new ArrayList<>();
	
	@Getter
	@Setter
	private int betAmountTotal = 0;
	
	private BettingRule rule;
	
	private List<Float> martinBenefitRateList = new ArrayList<>();
	
	public MartinCalculator_11(BettingRule rule) throws Exception{
		this.rule = rule;
		String[] strMartinBenefitRateList = rule.getString("martinBenefitRateList").split(",");
		for (String strMartinBenefitRate : strMartinBenefitRateList) {
			martinBenefitRateList.add(Float.parseFloat(strMartinBenefitRate.trim()));
		}
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
		List<OddsTItem> oddsItemList = new ArrayList<>();
		
		String[] kumibanList = rule.getString("kumibanMartinList").split(",");
		for (String kumiban : kumibanList) {
			OddsTItem oddsItem = OddsManager.getInstance().getOddsItem(race.setu.jyoCd, String.valueOf(race.raceInfo.no), rule.getString("type"), kumiban);
			if (oddsItem == null || oddsItem.value < rule.getFloat("minimunMartinOdds")) {
				continue;
			} else {
				oddsItemList.add(oddsItem);
			}
		}
		
		if (oddsItemList.size() < kumibanList.length) {
			race.multiplyType = RaceEx.MULTIPLY_UNDER_MINIMUM;
			return race;
		}
		
		oddsItemList.sort(new OddsTItemValueComparator());
		
		Float[] arrOdds = new Float[oddsItemList.size()];
		for (int i = 0; i < oddsItemList.size(); i++) {
			arrOdds[i] = oddsItemList.get(i).value;
		}
		
		int[] moneys = getMartinBetAmountList(betAmountTotal, arrOdds);
		
		int betAmountRace = 0;
		for (int i=0; i < moneys.length; i++) {
			Bet bet = new Bet(rule.getString("type"), arrOdds[i], moneys[i], 0, oddsItemList.get(i).kumiban);
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
		
		// martinCount is started from 0
		int martinCountIdx = getMartinCount();
		if (martinCountIdx >= martinBenefitRateList.size()) {
			martinCountIdx = martinBenefitRateList.size() - 1;
		}
		
		double value1 =  (double) (((float) (martinLoss) *  martinBenefitRateList.get(martinCountIdx) ) / (oddsList[0] - rateFactorF));
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
