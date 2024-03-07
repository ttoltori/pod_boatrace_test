package com.pengkong.boatrace.simulation2;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.pengkong.boatrace.model.DistamoItem;
import com.pengkong.boatrace.model.OddsTItem;
import com.pengkong.boatrace.simulation.model.BettingRule;
import com.pengkong.common.MathUtil;

public class DistributeAmount {

	public static final int STRATEGY_ATLEAST_FIRST = 1;
	public static final int STRATEGY_ATLEAST_1 = 2;
	public static final int STRATEGY_ALL = 3;
	public static final int STRATEGY_ATLEAST_FIRST_N = 4;
	
	public float factor1 = 1;
	public int baseAmount = 100;
	public int strategy = STRATEGY_ALL;
	private BettingRule rule;
	
	private float factorT;
	
	public DistributeAmount(BettingRule rule) throws Exception {
		this.rule = rule;
		this.strategy = rule.getInt("distamoStrategy");
		this.factor1 = rule.getFloat("distamoFactor1");
		this.baseAmount = rule.getInt("baseBetAmount");
	}
	
	public float getVirtualOdds(List<OddsTItem> oddsList) {
		float[] factors = new float[oddsList.size()];
		
		factors[0] = factor1;
		for (int i = 1; i < factors.length; i++) {
			factors[i] = oddsList.get(0).value / oddsList.get(i).value; 
		}
		
		factorT = MathUtil.sumOfFloatArray(factors); 
		
		return oddsList.get(0).value / factorT;
	}
	
	public List<DistamoItem> distribute(int startAmount, List<OddsTItem> oddsList, int maxAmount) throws Exception {
		int[] moneys = new int[oddsList.size()];
		List<DistamoItem> distamoList = new ArrayList<>();
		
		float[] factors = new float[oddsList.size()];
		
		factors[0] = factor1;
		for (int i = 1; i < factors.length; i++) {
			factors[i] = oddsList.get(0).value / oddsList.get(i).value; 
		}
		
		factorT = MathUtil.sumOfFloatArray(factors);
		
		while (true) {
			for (int i = 0; i < moneys.length; i++) {
				moneys[i] = MathUtil.ceilAmount( (float)startAmount * factors[i] / factorT, baseAmount);
			}

			if (isPrizeOk(moneys, oddsList)) {
				break;
			} else {
				startAmount += baseAmount;
				
				// 上限金額超過
				if (startAmount > maxAmount) {
					return null;
				}
			}
		}
		
		for (int i = 0; i < moneys.length; i++) {
			distamoList.add(new DistamoItem(oddsList.get(i).kumiban, oddsList.get(i).value, moneys[i]));
		}
		
		return distamoList;
	}
	
	private boolean isPrizeOk(int[] moneys, List<OddsTItem> oddsList) throws Exception {
		int[] prizes = new int[moneys.length];
		
		int betSum = Arrays.stream(moneys).sum();
		int plusCount = 0;
		for (int i = 0; i < prizes.length; i++) {
			prizes[i] = MathUtil.ceilAmount((float)moneys[i] * oddsList.get(i).value, 10);
			
			// 払戻が掛け金より小さい
			if (prizes[i] < betSum) {
				return false;
			} else if (prizes[i] > betSum) {
				plusCount++;
			}
		}

		if (strategy == DistributeAmount.STRATEGY_ALL) {
			if (plusCount < moneys.length) {
				return false;
			}
		} else if (strategy == DistributeAmount.STRATEGY_ATLEAST_1){
			if (plusCount <= 0) {
				return false;
			}
		} else if (strategy == DistributeAmount.STRATEGY_ATLEAST_FIRST){
			if (betSum > prizes[0]) {
				return false;
			}
		} else if (strategy == DistributeAmount.STRATEGY_ATLEAST_FIRST_N){
			int n = rule.getInt("distamoFirstNCount");
			int prizeSum = 0;
			for (int i = 0; i < n; i++) {
				prizeSum += prizes[i];
			}
			
			if (betSum > prizeSum) {
				return false;
			}
		}
		
		return true;
	}
	
}
