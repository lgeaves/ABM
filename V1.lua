-----------------------------------------------------------
-- model description FLAT INSURANCE / NO INCENTIVES
-----------------------------------------------------------
--In this model the PLPC influences the insurance cost
--There is no constrains on budget
--There are subsidies on insurance (insurance = the cost of damages x the probability of flooding)
--Insurance is based on individual risk, not community risk

-----------------------------------------------------------
-- model parameters
-----------------------------------------------------------

-- parameters for the householder x flood game 
ROUNDS  							= 125  		-- number of time steps
FLOODS_PROB							= 0.1  	-- probability of the flood occurring in any one year in the general area, not localised to household
FLOODS_PROB_INCREMENT				= (0.1 - FLOODS_PROB)/ROUNDS -- Can have increasing flood risk over the length of the game
												-- figure on the left is high flood risk value, figure on the right is starting flood risk.
INSURANCE_PROB 						= 0  		-- probability of householders buying insurance when his/her belief is zero
BUY_PLPP_PROB 						= 0 		-- probability to buy a PLP when his/her belief is zero
BUY_PLPC_PROB						= 0			-- probability to buy a PLP when his/her belief is zero
BUY_NOTHING_PROB					= 0			-- probability to buy nothing when belief is 0
BUY_SAVINGS_PROB					= 1 		-- probability the householder will get annual savings
												-- set to 1 so that each year there is an annual wage
AE_WEIGHTING						=0.5		-- agent preference for advice or experience. Advice = 1-AE_WEIGHTING

-- householder characteristics
MEMORY_LENGTH		= 10		-- how long the memory of a householder lasts
POTENTIAL_DAMAGE	= 30000		-- average claim of a householder affected by a flood

--Savings set as an option to purchase annually. Probability of purchasing = 1
STARTING_COSTS		= 0			-- The total costs that an agent begins a game with
SAVINGS_AMOUNT		= 10000		-- 2240
SAVINGS_LIFETIME	= 1			-- Savings are topped up annually
DOWNSCALE_DISCOUNT	= 10 		-- Percentage of lost wealth brought about by liquidating assets
LIQUID_ASSETS		= 100000	-- Value of liquid assets

-- insurance purchase
INSURANCE_COST 		= 398		-- average cost of insurance for a householder against flood (av = £398)
								-- not used in this game because insurance cost = self.risk * self.damage costs
INSURANCE_LIFETIME	= 1			-- how long a insurance policy lasts

-- property level protection
PLPP_COST			= 4700		-- average property level protection cost
PLPP_LIFETIME		= 7			-- how long a property level protection lasts

-- river plpc
PLPC_COST			= 10000		-- the cost of maintaining the river per year
PLPC_LIFETIME		= 30		-- how long the plpc of the river has an impact for

--Nothing 
NOTHING_COST		= 0			--The cost of buying nothing
NOTHING_LIFETIME	= 1			--The lifetime of nothing

-- Policy length of time for the transition for market price
POLICY_LENGTH		= 25 	-- Length of time there are market adjustments (i.e. Flood Re = 25 years)
SUBSIDY_TIME		= 125 	-- Length of time there is fully subsidised insurance
TRANSITION_LENGTH	= 10	-- Length of time to transition between subsidised and 'fair' price insurance
PREMIUM_COST		= 0	
EXCESS_COST			= 0
CLAIM_PROB			= 0
CLAIMMEMORY_LENGTH	= 5

-----------------------------------------------------------
-- Global constants
-----------------------------------------------------------

-- possible plays for the householder x flood game
-- for the householder

BUY_INSURANCE		= 1
NOT_BUY_INSURANCE	= 0

BUY_PLPP			= 1
NOT_BUY_PLPP		= 0

BUY_PLPC			= 1
NOT_BUY_PLPC		= 0

BUY_NOTHING			= 1	

BUY_WARNING			= 1 

CLAIM				= 1
NOT_CLAIM			= 0

-- for the flood
OCCUR				= 1
NOT_OCCUR			= 0

---wages / disposable income spent to spend on FRM
BUY_SAVINGS			= 1
NO_BUY_SAVINGS		= 0

-----------------------------------------------------------
-- Global variables
-----------------------------------------------------------

simulationTime = 0


-----------------------------------------------------------
-- Defining type of agents
-----------------------------------------------------------

-- The HOUSEHOLDER
Householder = Agent{

	payoff 					= {0, 0}, 					-- initial payoff
	memory 					= {} , 						-- memory of householder about recent floods	
	belief 					= 0,						-- householder belief that a flood will occur
	insurersBelief			= 0,
	
	totalCost				= 0,
	totalSavings			= 0,						-- Should this be SAVINGS_AMOUNT ?
	savingsLifetime			= SAVINGS_LIFETIME + 1,		-- How often income given to agent (set annually)
	actual_savings_prob		= 0,						-- probability the householder with have savings in any given year
	liquidAssets			= 0,						-- the value of assets liquidated within one game
	liquidateCount			= 0,						-- number of times in a round that householder liquidates assets
	
	plppLifetime 			= PLPP_LIFETIME + 1,   		-- actual lifetime of a householders PLP	
	plpcLifetime			= PLPC_LIFETIME + 1, 		-- actual lifetime of a householders plpc
	insuranceLifetime		= INSURANCE_LIFETIME + 1,	-- added 160115
	nothingLifetime			= NOTHING_LIFETIME + 1,		-- added 040515
	
	insuranceCost			= 0,
	plppCost				= 0,
	plpcCost				= 0,
	nothingCost				= NOTHING_COST,
	
	actual_insurance_prob 	= 0,						-- end insurance following changes as a result of actions	 
	actual_plpp_prob 		= 0,						-- end plp following changes as a result of actions
	actual_plpc_prob		= 0,						-- end plpc following changes as a result of actions
	actual_nothing_prob		= 0,						-- end nothing following changes due to actions
	
	action 					= 0,						-- the householder action (0 or 1)
	floodAction				= 0,						-- the flood action (0 or 1)
	
	future_flood_damage		= 1,						-- change in probability of future flood damage	costs
	actual_flood_damage		= 0,						-- end damage costs as a result of actions
	
	future_flood_prob		= 0,						-- change in probability of future flood (less floods when 0)	
	actual_flood_prob		= 0,						-- end flood probability following changes as a result of actions
	
	insuranceExpenses		= 0,						-- the amount spent on each
	PLPCExpenses			= 0,
	PLPPExpenses			= 0,
	floodExpenses			= 0,
	
	claimInsurance			= 0,
	notClaimInsurance		= 0,
	insuranceExcessCost		= 0,
	insurancePremiumCost	= 0,
	prob_claimInsurance		= 0,
	insurersBelief			= 0,
	claimMemory				= {} ,
	councilTaxCap			= 0, -- need to define this
	
	belief_flood_occurs		= 0, -- was already here. Maybe delete. 040515
	
	-- new variables 050515
	believed_emv_plpp 		=0,
	believed_emv_plpc 		=0,
	believed_emv_insurance 	=0,
	believed_emv_nothing 	=0,

	belief_future_flood 	=0,

	belief_plpp_works		=0,
	belief_plpc_works		=0,
	belief_insurance_works	=0,
	belief_nothing_works	=0,

	prob_chose_plpc			=0,
	prob_chose_plpp			=0,
	prob_chose_insurance	=0,
	prob_chose_nothing		=0,

	segment					=0,
	choice					=0,
	risk_info				=0,
	
	--new variables 080515
	claimMemory				= 0,
	claimInsurance			= 0,
	
	plppMemory				= 0,
	plppAction				= 0,
	
	plpcMemory				= 0,
	plpcAction				= 0,
	
	warningMemory			= 0,
	warningAction			= 0,
	
	prob_plpp_works			= 0.4,
	
----THIS IS WHERE IT ALL BEGINS!!

	execute = function(self)
		
	-- initial payoff for one round
		self.payoff = {0, 0}
		
----RISK INFORMATION
--[[
	if ( math.random() <= self.actual_warning_prob ) then 
			BUY_WARNING				= 1

	end 
]]--		
----MEMORY CALCULATIONS START
		
	-- Calculating householder belief -- may delete this after new section built
		if( #self.memory > 0 ) then 
			local count_flood = 0
			for k, v in ipairs(self.memory) do 
				count_flood = count_flood + v
			end 
			self.belief = count_flood / #self.memory
		else
			self.belief = 0
		end 
		
	-- Calculating householder belief that a flood will occur
		if( #self.memory > 0 ) then 
			local count_flood = 0
			for k, v in ipairs(self.memory) do 
				count_flood = count_flood + v
			end 
			self.belief_future_flood = count_flood / #self.memory
		else
			self.belief_future_flood = 0 	-- this is where to put influence from friends and information
											-- e.g. (AE_WEIGHTING*(count_flood / #self.memory))+((1-AE_WEIGHTING)*(self.risk_info)))
		end 
		
		
	--calculating insurers believe that the householder will claim
		if( #self.claimMemory > 0 ) then  -- this is going to have to be done on damage costs
			local count_claim = 0
			for k, v in ipairs(self.claimMemory) do 
				count_claim = count_claim + v
			end 
			self.insurersBelief = count_claim / #self.claimMemory
		else
			self.insurersBelief = 0
		end 
		
		--calculating householders belief that PLPP will work
		if( #self.insuranceMemory > 0 ) then  -- this is going to have to be done on damage costs
			local count_insurance = 0
			for k, v in ipairs(self.insuranceMemory) do 
				count_insurance = count_insurance + v
			end 
			self.belief_insurance_works = count_insurance / #self.insuranceMemory
		else
			self.belief_insurance_works = 0
		end
		
	--calculating householders belief that PLPP will work
		if( #self.plppMemory > 0 ) then  -- this is going to have to be done on damage costs
			local count_plpp = 0
			for k, v in ipairs(self.plppMemory) do 
				count_plpp = count_plpp + v
			end 
			self.belief_plpp_works = count_plpp / #self.plppMemory
		else
			self.belief_plpp_works = 0
		end
		
--calculating householders belief that PLPC will work
		if( #self.plpcMemory > 0 ) then  -- this is going to have to be done on damage costs
			local count_plpc = 0
			for k, v in ipairs(self.plpcMemory) do 
				count_plpp = count_plpc + v
			end 
			self.belief_plpc_works = count_plpc / #self.plpcMemory
		else
			self.belief_plpc_works = 0
		end
		
--calculating householders belief that Nothing will work
		if( #self.nothingMemory > 0 ) then  -- this is going to have to be done on damage costs
			local count_nothing = 0
			for k, v in ipairs(self.nothingMemory) do 
				count_plpp = count_nothing + v
			end 
			self.belief_nothing_works = count_nothing / #self.nothingMemory
		else
			self.belief_nothing_works = 0
		end
		
----MEMORY CALCULATIONS END
----SAVINGS CALCULATIONS START		
	-- probability that the householder will get annual savings
		self.actual_savings_prob	= BUY_SAVINGS_PROB 	--the probability of getting annual savings is based on entire game savings. Currently set to annual
		self.actual_warning_prob	= BUY_WARNINGS_PROB --should this be universal or based on the owners experience?? ---QUESTION!!!!!------
		
	-- Calculating flood probability (depending on householder actions)
		self.actual_flood_prob 		= FLOODS_PROB * self.future_flood_prob
		self.actual_flood_damage	= POTENTIAL_DAMAGE * self.future_flood_damage
	
	-- Calculating how much an agent has in savings after actions
		--self.totalSavings			= SAVINGS_AMOUNT -- annual savings amount
		self.totalSavings			= self.totalSavings + SAVINGS_AMOUNT -- Cumulative savings (adding itself makes it cumulative)
		self.totalCost				= self.totalCost + STARTING_COSTS
	
	--calculating the value of liquidating assets to spend on FRM options
		self.liquidAssets			= LIQUID_ASSETS * 0.1
	
	-- Householder gets annual disposable income	
		if( self.savingsLifetime >= SAVINGS_LIFETIME )then --wage is annual
			if( math.random() <= self.actual_savings_prob ) then 
				--print("****Annual Wage Delivered**** Total = "..self.totalSavings)  io.flush()
			else 
				--print("****NO ANNUAL WAGE****")  io.flush()
			end
		else
			self.savingsLifetime = self.savingsLifetime + 1
		end		

----SAVINGS CALCULATIONS END
----START: PROBABILITY OF CLAIMING INSURANCE		
			
		if (self.actual_flood_damage >= self.insuranceExcessCost) then -- need to know what motivates people to take out a claim.
			self.claimInsurance = 1
			--self.prob_claimInsurance =  math.min(INSURANCE_PROB + self.belief, 1)
		end
--[[Calculations for adding an insurance cap	
		if (self.actual_flood_prob * self.actual_flood_damage >=self.councilTaxCap) then
			self.insurancePremiumCost = self.councilTaxCap
		else
			self.insurancePremiumCost = self.actual_flood_prob * self.actual_flood_damage
		end

		if (self.insurersBelief * self.actual_flood_damage >= self.councilTaxCap) then
			self.insuranceExcessCost = self.councilTaxCap
		else
			self.insuranceExcessCost = self.insurersBelief * self.actual_flood_damage
		end
]]--
----END: PROBABILITY OF CLAIMING INSURANCE	
-------------------------------------------------------
----START: DEFINING THE COST OF OPTIONS FOR HOUSEHOLDER
		
	----PLP
		self.plppCost		= PLPP_COST
		self.plpcCost		= PLPC_COST
		
	----INSURANCE
--[[		if( simulationTime <= SUBSIDY_TIME) then 		--if simulation time is less than subsidy duration then 
			self.insuranceCost	= INSURANCE_COST 		-- people pay subsidized insurance
		else
			if( simulationTime <= POLICY_LENGTH) then 	-- if simulation time is smaller than policy length there is still partially subsidised insurance
				local percentage = (TRANSITION_LENGTH - ( POLICY_LENGTH - simulationTime))/TRANSITION_LENGTH
				self.insuranceCost	= (1 - percentage) * INSURANCE_COST + percentage * self.actual_flood_damage * self.actual_flood_prob -- was self.actual_flood_damage / self.actual_flood_prob
			else -- this is the 'fair' insurance price
				self.insuranceCost			= self.actual_flood_damage * self.actual_flood_prob
				self.insurancePremiumCost 	= self.actual_flood_damage * self.actual_flood_prob
				self.insuranceExcessCost	= 0.4(self.actual_flood_damage * self.actual_flood_prob) -- this is shit. Need to change.
			end
		end
--]]		

	self.insuranceCost			= self.actual_flood_damage * self.actual_flood_prob
	self.insurancePremiumCost 	= self.actual_flood_damage * self.actual_flood_prob
	self.insuranceExcessCost	= 0.4(self.actual_flood_damage * self.actual_flood_prob) -- this is shit. Need to change.

		
	----NOTHING 	
--	self.nothingCost		= NOTHING_COST
		
----END: DEFINING THE COST OF OPTIONS FOR HOUSEHOLDER		

		--print (simulationTime) io.flush()


----START: LIQUIDATING SAVINGS	
	-- MOVING!!!
--[[		
	if (self.totalSavings =< 0) then 
			self.totalSavings 	= self.totalSavings + self.liquidAssets
			print ("***sells property***") io.flush()
			self.liquidateCount	= self.liquidateCount + 1
			SAVINGS_AMOUNT		= SAVINGS_AMOUNT / DOWNSCALE_DISCOUNT -- after liquidating assets quality of life decreases	
			self.liquidAssets	= self.liquidAssets / DOWNSCALE_DISCOUNT -- after liquidating assets there are less assets to liquidate in the future	
	end	
		
		--DIE!!
		if(self.totalSavings <= 0) then
			self:die()
		end
--]]		
		

---------------------------------------------------------------------------------			
----------ACTIONS START HERE!!!!!!
---------------------------------------------------------------------------------
----EMV CALCULATIONS

-----//EMV PLPP//--------
if (self.totalSavings >= self.plppCost) then
	
	if (self.plppLifetime >= PLPP_LIFETIME) then 
	
		self.believed_emv_plpp 	= ((self.belief_future_flood * self.belief_plpp_works)*self.plppCost) 
								+ ((self.belief_future_flood*(1-belief_plpp_works))*(self.plppCost*self.future_flood_damage))
								+ ((1-self.belief_future_flood)*self.plppCost)
	else
	
		self.PLPLifetime = self.PLPLifetime + 1
			
			if (self.floodAction == 1) then
			
				if (math.random()<= self.prob_plpp_works) then
			
					self.plppAction		= 1 -- should it be self.plppAction + 1?
				
				else
			
					self.totalSavings 			= self.totalSavings - self.actual_flood_damage
					self.totalCost				= self.totalCost + self.actual_flood_damage
	
				end
			
			end
	end
else
	self.believed_emv_plpp = 0
end

-----//EMV PLPC//--------
if (self.totalSavings >= self.plpcCost) then

	if(self.plpcLifetime >= PLPC_LIFETIME ) then 
	
		self.believed_emv_plpc 	= ((self.belief_future_flood * self.belief_plpc_works)*self.plpcCost) 
							+ ((self.belief_future_flood*(1-belief_plpc_works))*(self.plpcCost*self.future_flood_damage))
							+ ((1-self.belief_future_flood)*self.plpcCost)
	
	else
		
		self.PLPCLifetime = self.PLPCLifetime + 1
			
			if (self.floodAction == 1) then
			
				self.plpcAction			= 1 
				self.totalSavings 		= self.totalSavings - self.plpcCost + (self.actual_flood_damage*0.16) -- EA says that PLP can reduce your damage claims by 84%
				self.totalCost			= self.totalCost + self.plpcCost - (self.actual_flood_damage*0.16)
			
			end
	end
	
else	
	self.believed_emv_plpc = 0
end

-----//EMV INSURANCE//--------

if (self.totalSavings >= self.insuranceCost) then -- don't need lifetime as only one year
	
	self.believed_emv_insurance	= ((self.belief_future_flood * self.belief_insurance_works)*(self.insuranceCost+self.claimsCost))
								+ ((self.belief_future_flood*(1-belief_insurance_works))*(self.insuranceCost*self.future_flood_damage))
								+ ((1-self.belief_future_flood)*self.insuranceCost)
else	
	self.believed_emv_insurance = 0
end

-----//EMV NOTHING//--------

if (self.totalSavings >= NOTHING_COST) then 
	self.believed_emv_nothing	= ((self.belief_future_flood * self.belief_nothing_works)*NOTHING_COST)
								+ ((self.belief_future_flood*(1-belief_nothing_works))*(NOTHING_COST*self.future_flood_damage))
								+ ((1-self.belief_future_flood)*NOTHING_COST)
else	
	self.believed_emv_nothing = 0
end

self.segment = (1/(self.believed_emv_insurance+self.believed_emv_nothing+self.believed_emv_plpc+self.believed_emv_plpp)) --maybe take away the ^-1

self.prob_chose_plpp 		= (1-(self.segment*self.believed_emv_plpp))
self.prob_chose_plpc 		= (1-(self.segment*self.believed_emv_plpc))
self.prob_chose_insurance 	= (1-(self.segment*self.believed_emv_insurance))
self.prob_chose_nothing 	= (1-(self.segment*self.believed_emv_nothing))

self.choice = math.max (self.prob_chose_plpp, self.prob_chose_plpc, self.prob_chose_plpc, self.prob_chose_plpp)


----HOUSEHOLDER BUYS 1 YEAR INSURANCE POLICY
	if self.choice = self.prob_chose_insurance then
	
		print ("Chooses Insurance") io.flush()
		self.totalSavings 		= self.totalSavings 		- self.insurancePremiumCost -- if no flood then only the cost of insurance
		self.totalCost			= self.totalCost 			+ self.insurancePremiumCost
		self.insuranceExpenses 	= self.insuranceExpenses 	+ self.insurancePremiumCost

			if (self.floodAction == 1) then
				
				if (self.claimInsurance == 1) then
							
					self.claimInsurance			= 1
					self.insuranceAction		= 1
					self.totalSavings 			= self.totalSavings 		- self.insuranceExcessCost + self.actual_flood_damage
					self.totalCost				= self.totalCost 			+ self.insuranceExcessCost - self.actual_flood_damage
					self.insuranceExpenses 		= self.insuranceExpenses 	+ self.insuranceExcessCost -- work out insurance excess cost
								
				else 
					
					self.totalSavings 			= self.totalSavings 		- self.actual_flood_damage
					self.totalCost				= self.totalCost 			+ self.actual_flood_damage
							
				end
				
			end											-- if there is a flood the flood damage costs are neutralised
	
	end

----HOUSEHOLDER BUYS PLPP
				
	if self.choice = self.prob_chose_plpp then
	
		print ("Chooses PLPP") io.flush()
		self.totalSavings 			= self.totalSavings - self.plpCost
		self.PLPPExpenses			= self.PLPPExpenses + self.plpCost
		self.totalCost				= self.totalCost + self.plpCost
		
		if (self.floodAction == 1) then
			
			if (math.random()<= self.prob_plpp_works) then
			
				self.plppAction		= 1 -- should it be self.plppAction + 1?
				
			else
			
				self.totalSavings 			= self.totalSavings - self.actual_flood_damage
				self.totalCost				= self.totalCost + self.actual_flood_damage
	
			end
			
		end
	end
	
		
---- HOUSEHOLDER BUYS PLPC		
	if self.choice = self.prob_chose_plpp then
		
		print ("Chooses PLPC") io.flush()
		self.PLPCExpenses			= self.PLPCExpenses + self.plpcCost
		self.totalCost				= self.totalCost + self.plpcCost
		self.totalSavings 			= self.totalSavings - self.plpcCost
			
			if (self.floodAction == 1) then
			
				self.plpcAction			= 1 
				self.totalSavings 		= self.totalSavings - self.plpcCost + (self.actual_flood_damage*0.16) -- EA says that PLP can reduce your damage claims by 84%
				self.totalCost			= self.totalCost + self.plpcCost - (self.actual_flood_damage*0.16)
			
			end
		
	end
	
----HOUSEHOLDER BUYS NOTHING
	if self.choice = self.prob_chose_nothing then
		print ("Chooses Nothing") io.flush()
	
		if (self.floodAction == 1) then
			
			self.totalSavings 		= self.totalSavings - self.actual_flood_damage
			self.totalCost			= self.totalCost + self.actual_flood_damage
				
		end
			
	end
		
----FLOOD DECISION AFTER HUMAN DECISION
	
	if ( math.random() <= self.actual_flood_prob ) then 
			OCCUR					= 1 --added 050515
			self.floodAction 		= 1
			print ("FLOOD OCCURS -- damage:"..self.actual_flood_damage) io.flush()
			print ("Remaining Savings FOLLOWING FLOOD: "..self.totalSavings) io.flush()
	else 
			self.floodAction	 	= 0 
			--print ("NO FLOOD") io.flush()
	end
		
						
		-------
		function insuranceGame(householder, flood)
		
			if householder == BUY_INSURANCE     and flood == OCCUR     then return {(self.totalSavings - self.insuranceCost ), (1) } end
			if householder == BUY_INSURANCE     and flood == NOT_OCCUR then return {(self.totalSavings - self.insuranceCost ), (0)} end
			if householder == NOT_BUY_INSURANCE and flood == OCCUR     then return {(self.totalSavings - self.actual_flood_damage), (1)}  end
			if householder == NOT_BUY_INSURANCE and flood == NOT_OCCUR then return {(self.totalSavings), (0)} end
			
		end
		-------
	
	
		-- Householder memorises the flood action
		self.memory[(simulationTime % MEMORY_LENGTH) + 1] = self.floodAction
		--print("memory:", (time % MEMORY_LENGTH) + 1, householder_memory[(time % MEMORY_LENGTH) + 1])io.flush()
		
		self.claimMemory	[(simulationTime % CLAIMMEMORY_LENGTH) + 1] = self.claimInsurance
		self.insuranceMemory[(simulationTime % MEMORY_LENGTH) + 1] 		= self.insuranceAction
		self.plppMemory		[(simulationTime % MEMORY_LENGTH) + 1] 		= self.plppAction
		self.plpcMemory		[(simulationTime % MEMORY_LENGTH) + 1] 		= self.plpcAction
		self.warningMemory	[(simulationTime % MEMORY_LENGTH) + 1] 		= self.warningAction
		self.nothingMemory	[(simulationTime % MEMORY_LENGTH) + 1] 		= self.nothingAction
		
		local oneGamePayoff = insuranceGame( self.action , self.floodAction )
		
		self.payoff = {self.payoff[1] + oneGamePayoff[1], self.payoff[2] + oneGamePayoff[2]}
		
	end
} ---END OF HOUSEHOLDER AGENT



householders = Society{instance = Householder, quantity = 1} -- change quantity depending on number of residents in community




---- A UNIT TEST TO VERIFY MODEL
--[[
function unitTest( )
	local payoff = insuranceGame( 1 , 1 )
	assert(payoff[1] == 27000	, "payoff[1] = "..payoff[1]) 
	assert(payoff[2] == 30000	, "payoff[2] = "..payoff[2]) 
	
	payoff = insuranceGame( 1 , 0 )
	assert(payoff[1] == -3000	, "payoff[1] = "..payoff[1]) 
	assert(payoff[2] == 0		, "payoff[2] = "..payoff[2]) 
	
	payoff = insuranceGame( 0 , 1 )
	assert(payoff[1] == -30000	, "payoff[1] = "..payoff[1]) 
	assert(payoff[2] == 30000	, "payoff[2] = "..payoff[2]) 
	
	payoff = insuranceGame( 0 , 0 )
	assert(payoff[1] == 0		, "payoff[1] = "..payoff[1]) 
	assert(payoff[2] == 0		, "payoff[2] = "..payoff[2]) 
end
--]]
--unitTest( ) os.exit()


-- Choosing a random seed 
seed = os.time()
--seed = 1375798415
--seed = 1375773832

math.randomseed( seed )

----SAVING OUTPUTS TO EXCEL 
logFile = io.open("c:\\Users\\Linda\\log.csv", "w+") -- This is where my log file gets saved
logFile:write("time\tagent\ttotalCost\tliquidation\tinsuranceExpenses\tPLPCExpenses\tPLPPExpenses\tfloodExpenses\n") -- These are the columns of the spreadsheet \t = new tab \n closes the sheet

-- Game dynamics (many game rounds)
totalPayoff = {0,0}
t = Timer{
	Event{time = 0, 	action = function(event)
		simulationTime = event:getTime()

		--local payoff = calculatePayoff()

		householders:execute( )
		--householders:notify()
		
	
		forEachAgent( householders, function(ag)
			
			local line = ""	
			
			line = line..simulationTime.."\t"
			line = line..ag.id.."\t"
			line = line..ag.totalCost.."\t"
			line = line..ag.liquidateCount.."\t"
			line = line..ag.insuranceCost.."\t"
			line = line..ag.plpcCost.."\t"
			line = line..ag.plppCost.."\t"
			line = line..ag.floodExpenses.."\n"

			--print (simulationTime) 
					--"ROUND","("..ag.action..","..ag.floodAction..") = ", 
		    --print ("("..ag.payoff[1]..","..ag.payoff[2]..")")   
		    --print ("agent actual flood prob: "..ag.actual_flood_prob)
			--print ("agent actual flood damage:"..ag.actual_flood_damage)
			--print ("belief in flood prob: "..ag.belief)			
		    --print ("prob buy insurance: "..ag.actual_insurance_prob) 
			--print ("prob buy plpp: "..ag.actual_plpp_prob) 
		    --print ("prob buy plpc: "..ag.actual_plpc_prob)
			--print ("insurance cost:"..ag.insuranceCost)
			--print ("agent future flood probability: "..ag.future_flood_prob)
			--print ("END ROUND")
			
			print ("total cost:"..ag.totalCost, "of which are damage"..ag.floodExpenses,"of which are insurance"..ag.insuranceCost,"of which are plpp"..ag.plppCost, "of which are PLPC"..ag.plpcCost)
			print ("total cost:"..ag.totalCost/125, "of which are damage"..ag.floodExpenses/125,"of which are insurance: "..ag.insuranceCost/125,"of which are plpp"..ag.plppCost/125, "of which are PLPC: "..ag.plpcCost/125)


		    io.flush()
		
			logFile:write(line)

			totalPayoff = {totalPayoff[1] + ag.payoff[1], totalPayoff[2] + ag.payoff[2]}
		end)
		
		
		FLOODS_PROB = FLOODS_PROB + FLOODS_PROB_INCREMENT
	end}
}

t:execute(ROUNDS)

logFile:close()

print("Seed: ", seed)
--print("PAYOFF:","Householder = "..totalPayoff[1], "Flood = "..totalPayoff[2]) -- was totalPayoff[2]/30000)


print("READY")
print("Pretty please, press <ENTER> to quit.")
--io.read()





