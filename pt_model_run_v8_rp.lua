------------------------------------------------------------------
----Universal Variables
------------------------------------------------------------------

ROUNDS			= 30 		-- number of rounds simulation is run
FLOOD_PROB		= 0.01		-- probability of flooding

FLOODS_PROB		= 0.01  	-- probability of the flood occurring in any one year in the general area, not localised to household
FLOODS_PROB_INCREMENT	= (0.01 - FLOODS_PROB)/ROUNDS -- increase of probability of flooding, due to climate change etc.

POTENTIAL_DAMAGE	= -30000	-- average cost of damge for a household during a flood (referenced in thesis)

POLICY_LENGTH		= 25		-- duration of policy instrucment subsidising flood insurance
TRANSITION_LENGTH 	= 10		-- duration that policy transitions to risk reflective pricing

PLPP_COST		= -4700		-- cheapest cost of property level protection
PLPP_LIFETIME		= 5		-- average lifetime of property level protection

NOTHING_COST		= 0		-- the cost of doing nothing!

WAVE 			= 2.25 		--loss aversion
FISH			= 0.88 		--
PROB_W_GAINS		= 0.61		-- probability weighting gains
PROB_W_LOSS		= 0.69		-- probability weighting losses

simulationTime 		= 0

------------------------------------------------------------------
----Agent Variables
------------------------------------------------------------------
Householder = Agent{

memory				= {},
insmemory			= {},
simulation_time			= simulationTime,
hh_bracket			= 0,
start_savings			= 0,
insurance_cap			= 0,
insurance_max			= 0,
account_balance			= 0,
damage				= 0,
flood_damage			= 0,

purchaseInsurance		= 0,
purchaseNothing			= 0,
purchaseInsuranceCap		= 0,
actual_flood_prob		= FLOODS_PROB, 
purchasePlpp			= 0,

belief_ff 			= 1, -- need calc
belief_ins_works		= 1, -- in memory later
belief_plpp_works		= 0.87, -- in memory later
belief_ins_plpp_works 		= 0.95,
belief_nothing_works		= 0,

insuranceCost			= 0,
nothCost			= NOTHING_COST,
plppCost 			= PLPP_COST,
plppInsCost			= 0,
insExcessCost			= 0,

believed_emv_plppins		= 0,
believed_emv_plpp		= 0,
believed_emv_ins		= 0,
believed_emv_noth		= 0,
belief_ff			= 0, 

floodAction 			= 0,

rp				= 0,
rp_exp				= 0,
average_ins			= 0,


pt_ins				= 0,
pt_noth				= 0,

insExpenses			= 0,
countFlood			= 0,

rp_exp_count			= 0,
rp_savings_count		= 0,
rp_ins_count			= 0,
insurance_count			= 0,

pt_ins_op1 			= 0,
pt_ins_op2 			= 0,
		
pt_noth_op1 			= 0,
pt_noth_op2 			= 0,
pt_ins_op2i			= 0,
pt_noth_op2i			= 0,

pt_plpp_op1			= 0,
pt_plpp_op2i			= 0,
pt_plpp_op2			= 0,
pt_plppins_op1			= 0,
pt_plppins_op2i			= 0,
pt_plppins_op2			= 0,

pt_plpp				= 0,
pt_plppins			= 0,

p_buy_ins_t			= 0,
p_buy_ins_rr			= 0,
p_buy_ins_cap			= 0,
p_buy_noth			= 0,
p_buy_plpp			= 0,
p_rp_ins			= 0,
p_rp_exp			= 0,
p_rp_sav			= 0,

avInsCost 			= 0,


execute = function(self)

------------------------------------------------------------------
----Memory
------------------------------------------------------------------
	if( #self.memory > 0 ) then 
		local count_flood = 0
		for k, v in ipairs(self.memory) do 
			count_flood = count_flood + v
		end 
			self.belief = count_flood / #self.memory
			self.belief_ff = count_flood / #self.memory
			self.count_flood = count_flood
	else
		self.belief = 0
		self.belief_ff = 0
		
	end


-------------------------------------------------------------------------------------------
-----What hh bracket will they be in, how will this influence savings and cap insurance???
-------------------------------------------------------------------------------------------
if (simulationTime <=0) then
	self.hh_bracket	=  9 --math.random (1,9)
	
	if (self.hh_bracket == 1) then
		self.start_savings = math.random (0,1194)
		self.insurance_cap = -210
		self.damage = POTENTIAL_DAMAGE * 0.2
	end
	if (self.hh_bracket == 2) then
		self.start_savings = math.random (398,1558)
		self.insurance_cap = -210
		self.damage = POTENTIAL_DAMAGE * 0.4
	end
	if (self.hh_bracket == 3) then
		self.start_savings = math.random (517, 2029)
		self.insurance_cap = -246 --36
		self.damage = POTENTIAL_DAMAGE * 0.6
	end
	if (self.hh_bracket == 4) then
		self.start_savings = math.random (676, 2954)
		self.insurance_cap = -276 --20 -- 16
		self.damage = POTENTIAL_DAMAGE * 0.8
	end
	if (self.hh_bracket == 5) then
		self.start_savings = math.random (985, 3581)
		self.insurance_cap = -330 --54 --34
		self.damage = POTENTIAL_DAMAGE 
	end
	if (self.hh_bracket == 6) then
		self.start_savings = math.random (1194, 4775)
		self.insurance_cap = -408 --72 --18
		self.damage = POTENTIAL_DAMAGE * 2
	end
	if (self.hh_bracket == 7) then
		self.start_savings = math.random (1592, 9550)
		self.insurance_cap = -540 --132 --60
		self.damage = POTENTIAL_DAMAGE * 4
	end
	if (self.hh_bracket == 8) then
		self.start_savings = math.random (3183, 12652)
		self.insurance_cap = -600
		self.damage = POTENTIAL_DAMAGE * 6
	end
	if (self.hh_bracket == 9) then
		self.start_savings = math.random (4217, 19397)
		self.insurance_cap = -700
		self.damage = POTENTIAL_DAMAGE * 8
	end
else
	self.start_savings = self.account_balance
	self.insurance_cap = self.insurance_max
	self.damage	= self.flood_damage
end

self.flood_damage			= self.damage
self.account_balance 		= self.start_savings
self.insurance_max 			= self.insurance_cap
self.plppInsCost			= (self.plppCost/PLPP_LIFETIME) + self.insuranceCost
self.belief_ins_plpp_works	= (self.belief_plpp_works*self.belief_ins_works)
self.insExcessCost 			= ((FLOODS_PROB*0.1)*(self.insuranceCost)) 
self.rp_exp 				= self.flood_damage
-----------------------------------------------------------
self.insurance_count		= self.purchaseInsuranceCap + self.purchaseInsurance
-----------------------------------------------------------
self.rp_savings				= self.account_balance


------------------------------------------------------------------
----What will the cost of their insurance be???
------------------------------------------------------------------

--print ("self.insExpenses / self.insurance_count: "..self.insExpenses / self.insurance_count)
--print ("****ST: "..simulationTime)

--self.insuranceCost		= (self.flood_damage * FLOODS_PROB)
--self.insuranceCost	= math.max (self.insurance_max, (self.flood_damage * FLOODS_PROB))

	if( simulationTime <= 15) then
		self.insuranceCost	= math.max (self.insurance_max, (self.flood_damage * FLOODS_PROB))

	else
		if( simulationTime <= POLICY_LENGTH) then
			local percentage = (TRANSITION_LENGTH - ( POLICY_LENGTH - simulationTime))/TRANSITION_LENGTH
			self.insuranceCost		= ((1 - percentage) * (math.max (self.insurance_max, (self.flood_damage * FLOODS_PROB))) + percentage * self.flood_damage * FLOODS_PROB) -- was self.actual_flood_damage / FLOODS_PROB
					
		else
			self.insuranceCost		= (self.flood_damage * FLOODS_PROB)
		end
	end
	

	
--------------------------------------------------------------------------------
------------------------------------------------------------------
----Will there be a flood?
------------------------------------------------------------------
if (math.random () <= FLOODS_PROB) then
	self.floodAction =  self.floodAction + 1
	self.countFlood	= self.countFlood + 1
	--print ("true")
end
-------------------------------------------------------------------
----DEFINING THE REFERENCE POINT
-------------------------------------------------------------------


if (self.countFlood >= (simulationTime / 3)) then -- needs to be total damages, perhaps; not number of floods
	self.rp = self.rp_exp
else
	if (self.insurance_count >= simulationTime / 3) then -- here I am defining what frequency of purchase makes purchasing insurance normal. It's arbitrary but it's a prototype.
		self.rp = self.rp_ins
		--print ("true")
	else
		self.rp = self.rp_savings
		--print ("false")
	end
end
--print ("self.insurance_count: "..self.insurance_count)
--print ("simulationTime / 5: "..simulationTime / 5)


-------------------------------------------------------------------
----PT STUFF
-------------------------------------------------------------------

if (self.rp == self.rp_ins) then -- if you usually buy insurance then purchasing an insurance is considered as a gain
	
	self.rp_ins_count	= self.rp_ins_count + 1
	--print ("Number of times insurance is preferred RP:"..self.rp_ins_count)
	self.p_rp_ins		= 1
	
	if ((self.insuranceCost - (self.rp))>= 0) then
	--print ("GAIN")

		self.pt_ins_op1 = (self.insuranceCost - self.rp)^0.88
		self.pt_ins_op2i = -1*((self.insuranceCost + self.insExcessCost)- self.rp)
		self.pt_ins_op2 = 0-(math.pow(self.pt_ins_op2i,0.88)) 		
		
		self.pt_noth_op1 = (self.nothCost - self.rp)^(0.88)
		self.pt_noth_op2i = -1*((self.nothCost + self.flood_damage)- self.rp)
		self.pt_noth_op2 = 0-(math.pow(self.pt_noth_op2i,0.88))
		
		self.pt_plpp_op1 = (self.plppCost - self.rp)^(0.88)
		self.pt_plpp_op2i = -1*((self.plppCost + self.flood_damage)- self.rp)
		self.pt_plpp_op2 = 0-(math.pow(self.pt_plpp_op2i,0.88))
		
		self.pt_plppins_op1 = (self.plppCost + self.insuranceCost) - self.rp^(0.88)
		self.pt_plppins_op2i = -1*((self.plppCost + self.insuranceCost + self.insExcessCost + self.flood_damage)- self.rp)
		self.pt_plppins_op2 = 0-(math.pow(self.pt_plpp_op2i,0.88))
		
		self.pt_ins	= 	((PROB_W_GAINS*(1-FLOODS_PROB))*self.pt_ins_op1)+
						((PROB_W_GAINS*(FLOODS_PROB))*self.pt_ins_op2)

		self.pt_noth= 	((PROB_W_GAINS*(1-FLOODS_PROB))*(self.pt_noth_op1))+
						((PROB_W_GAINS*(FLOODS_PROB))*(self.pt_noth_op2))	
						
		self.pt_plpp = 	((PROB_W_GAINS*(1-(0.4*FLOODS_PROB)))*(self.pt_plpp_op1))+
						((PROB_W_GAINS*(0.4*FLOODS_PROB))*(self.pt_plpp_op2))	
						
		self.pt_plppins = ((PROB_W_GAINS*(1-(0.4*FLOODS_PROB)))*(self.pt_plppins_op1))+
						((PROB_W_GAINS*(0.4*FLOODS_PROB))*(self.pt_plppins_op2))	
						
	else
	--print ("LOSS")
	
		self.pt_ins	= 	(((PROB_W_LOSS*(1-FLOODS_PROB))*
						(-WAVE*(((self.insuranceCost - self.rp)^2)^0.5)^0.88))+
						((PROB_W_LOSS*(FLOODS_PROB))*
						(-WAVE*((((self.insuranceCost + self.insExcessCost) - self.rp)^2)^0.5)^0.88)))
		
		self.pt_noth= 	(((PROB_W_LOSS*(1-FLOODS_PROB))*
						(-WAVE*(((self.nothCost - self.rp)^2)^0.5)^0.88))+
						((PROB_W_LOSS*(FLOODS_PROB))*
						(-WAVE*((((self.nothCost + self.flood_damage) - self.rp)^2)^0.5)^0.88)))

		self.pt_plpp= 	((PROB_W_LOSS*(1-FLOODS_PROB))*
						(-WAVE*(((((self.plppCost) - self.rp)^2)^0.5)^0.88))+
						((PROB_W_LOSS*(FLOODS_PROB))*
						(-WAVE*((((self.plppCost + self.flood_damage) - self.rp)^2)^0.5)^0.88)))
						
		self.pt_plppins= 	((PROB_W_LOSS*(1-FLOODS_PROB))*	
						(-WAVE*((((((self.plppCost) + (self.insuranceCost)) - self.rp)^2)^0.5)^0.88))+
						((PROB_W_LOSS*(FLOODS_PROB))*
						(-WAVE*((((self.plppCost + self.insuranceCost + self.insExcessCost + self.flood_damage) - self.rp)^2)^0.5)^0.88)))
					
				
	end
else
self.p_rp_ins		= 0
	
end

if (self.rp == self.rp_savings) then -- if you don't usually buy insurance then purchasing an insurance is considered as a loss

	self.rp_savings_count	= self.rp_savings_count + 1
	--print ("Number of time savings are preferred RP:"..self.rp_savings_count)
	self.p_rp_sav			= 1
	
		
		
		self.pt_ins	= 	(((PROB_W_LOSS*(1-FLOODS_PROB))*
						(-WAVE*(((self.insuranceCost - self.rp)^2)^0.5)^0.88))+
						((PROB_W_LOSS*(FLOODS_PROB))*
						(-WAVE*((((self.insuranceCost + self.insExcessCost) - self.rp)^2)^0.5)^0.88)))
		
		self.pt_noth= 	(((PROB_W_LOSS*(1-FLOODS_PROB))*
		
						(-WAVE*(((self.nothCost - self.rp)^2)^0.5)^0.88))+
						
						((PROB_W_LOSS*(FLOODS_PROB))*
						
						(-WAVE*((((self.nothCost + self.flood_damage) - self.rp)^2)^0.5)^0.88)))
		
		self.pt_plpp= 	((PROB_W_LOSS*(1-FLOODS_PROB))*
						(-WAVE*(((((self.plppCost) - self.rp)^2)^0.5)^0.88))+
						((PROB_W_LOSS*(FLOODS_PROB))*
						(-WAVE*((((self.plppCost + self.flood_damage) - self.rp)^2)^0.5)^0.88)))
						
		self.pt_plppins= 	((PROB_W_LOSS*(1-FLOODS_PROB))*
						(-WAVE*((((((self.plppCost) + (self.insuranceCost)) - self.rp)^2)^0.5)^0.88))+
						((PROB_W_LOSS*(FLOODS_PROB))*
						(-WAVE*((((self.plppCost + self.insuranceCost + self.insExcessCost + self.flood_damage) - self.rp)^2)^0.5)^0.88)))
		

							
else
self.p_rp_sav			= 0		
end

if (self.rp == self.rp_exp) then -- if you usually buy insurance then purchasing an insurance is considered as a gain

	self.rp_exp_count	= self.rp_exp_count + 1
	--print ("Number of time damages are preferred RP:"..self.rp_exp_count)
	self.p_rp_exp		= 1

		self.pt_ins_op1 = (self.insuranceCost - self.rp)^0.88
		self.pt_ins_op2i = ((self.insuranceCost + self.insExcessCost)- (self.rp)) --(-20 + -210) - (-12000)
		self.pt_ins_op2 = (math.pow(self.pt_ins_op2i,0.88)) 		
		
		self.pt_noth_op1 = (self.nothCost - (self.rp))^(0.88)
		self.pt_noth_op2i = ((self.nothCost + self.flood_damage)- (self.rp))
		self.pt_noth_op2 = (math.pow(self.pt_noth_op2i,0.88))
		
		self.pt_plpp_op1 = (self.plppCost - self.rp)^(0.88)
		self.pt_plpp_op2i = -1*((self.plppCost + self.flood_damage)- self.rp)
		self.pt_plpp_op2 = 0-(math.pow(self.pt_plpp_op2i,0.88))
		
		self.pt_plppins_op1 = ((self.plppCost + self.insuranceCost) - self.rp)^(0.88)
		self.pt_plppins_op2i = -1*((self.plppCost + self.insuranceCost + self.insExcessCost + self.flood_damage)- self.rp)
		self.pt_plppins_op2 = 0-(math.pow(self.pt_plpp_op2i,0.88))

		
		self.pt_ins	= 	((PROB_W_GAINS*(1-FLOODS_PROB))*self.pt_ins_op1)+
						((PROB_W_GAINS*(FLOODS_PROB))*self.pt_ins_op2)
		
		self.pt_noth= 	((PROB_W_GAINS*(1-FLOODS_PROB))*(self.pt_noth_op1))+
						((PROB_W_GAINS*(FLOODS_PROB))*(self.pt_noth_op2))	
						
		self.pt_plpp= 	((PROB_W_GAINS*(1-(0.4*FLOODS_PROB)))*(self.pt_plpp_op1))+
						((PROB_W_GAINS*(0.4*FLOODS_PROB))*(self.pt_plpp_op2))	
						
		self.pt_plppins = ((PROB_W_GAINS*(1-(0.4*FLOODS_PROB)))*(self.pt_plppins_op1))+
						((PROB_W_GAINS*(0.4*FLOODS_PROB))*(self.pt_plppins_op2))	
						

else
self.p_rp_exp		= 0
end



self.choice = (math.max (self.pt_ins, self.pt_noth, self.pt_plpp, self.pt_plppins))

-------------------------------------------------------------------
----will they won't they will they won't they buy the insurance????
-------------------------------------------------------------------
--print ("choice ins PO: "..self.pt_ins)
--print ("choice noth PO: "..self.pt_noth)
--print ("FLOODS_PROB: "..FLOODS_PROB)

if (self.choice == self.pt_insplpp) then
	if (self.account_balance >= (self.insuranceCost+self.plppCost)) then
		if (self.insuranceCost ==  self.insurance_max) then
			self.purchaseInsuranceCap = self.purchaseInsuranceCap + 1
			self.purchasePlpp 		= self.purchasePlpp + 1
			self.p_buy_plpp				= 1 
			self.p_buy_ins_cap			= 1
			self.p_buy_ins_rr			= 0
			self.p_buy_ins_t			= 1
			self.p_buy_noth				= 0
			--print ("blah end 1")
		else
			self.purchaseInsurance = self.purchaseInsurance + 1
			self.purchasePlpp 		= self.purchasePlpp + 1
			self.p_buy_plpp				= 1 
			self.p_buy_ins_cap			= 0
			self.p_buy_ins_rr			= 1
			self.p_buy_ins_t			= 1
			self.p_buy_noth				= 0
			--print ("blah end 2")
		end
		
	else
		
		self.choice = (math.max (self.pt_plpp, self.pt_ins, self.pt_noth)	)
		--print ("blah end 3")
	end
else
		if (self.choice == self.pt_ins) then
			if (self.account_balance >= self.insuranceCost) then
				if (self.insuranceCost ==  self.insurance_max) then
					self.purchaseInsuranceCap = self.purchaseInsuranceCap + 1
					self.p_buy_plpp				= 0 
					self.p_buy_ins_cap			= 1
					self.p_buy_ins_rr			= 0
					self.p_buy_ins_t			= 1
					self.p_buy_noth				= 0
					--print ("blah end 4")
				else
					self.purchaseInsurance = self.purchaseInsurance + 1
					self.p_buy_plpp				= 0 
					self.p_buy_ins_cap			= 0
					self.p_buy_ins_rr			= 1
					self.p_buy_ins_t			= 1
					self.p_buy_noth				= 0
					--print ("blah end 5")
				end
			else
			self.choice = (math.max (self.pt_plpp, self.pt_plppins, self.pt_noth))
			--print ("blah end 6")
			end	
	else
		
			if (self.choice == self.pt_plpp) then
				if (self.account_balance >= self.plppCost) then
					self.purchasePlpp = self.purchasePlpp + 1
					self.p_buy_plpp				= 1 
					self.p_buy_ins_cap			= 0
					self.p_buy_ins_rr			= 0
					self.p_buy_ins_t			= 0
					self.p_buy_noth				= 0
					--print ("blah end 7")
				else
				self.choice = (math.max (self.pt_ins, self.pt_plppins, self.pt_noth))
				--print ("blah end 8")
				end	
		else 
			if(self.choice == self.pt_noth) then
				self.purchaseNothing = self.purchaseNothing + 1
				self.p_buy_plpp				= 0 
				self.p_buy_ins_cap			= 0
				self.p_buy_ins_rr			= 0
				self.p_buy_ins_t			= 0
				self.p_buy_noth				= 1
				--print ("blah end 9")
				
			else
				self.choice = (math.max (self.pt_plpp, self.pt_plppins, self.pt_ins))
				--print ("blah end 10")
			end
		end
	end
end
--print ("self.purchaseInsuranceCap: "..self.purchaseInsuranceCap)
--print ("self.purchaseInsurance: "..self.purchaseInsurance)
--print ("self.purchaseNothing: "..self.purchaseNothing)

self.p_buy_ins_cap			= 1
self.p_buy_ins_rr			= 0
self.p_buy_ins_t			= 1

if (self.p_buy_noth	== 0) and (self.p_buy_plpp == 0)then
		--print ("memory activated "..simulationTime)
		if( #self.insmemory > 0 ) then 
			local insExpenses_t = self.insuranceCost 
			for k, v in ipairs(self.insmemory) do 
			insExpenses_x = (insExpenses_t + v)+ (simulationTime-1)
			end 			
		self.avInsCost = insExpenses_x	
		--print ("self.avInsCost: "..self.avInsCost)
		end
end



self.rp_ins = self.avInsCost -- (was self.purchaseInsurance)because the number of times the ins is purchased could be 0 meaning that an error occurs because a number is divided by 0, perhaps consider putting a math.max or somethings.
--print ("self.rp_ins: "..self.rp_ins)
--print ("self.insurance_count: "..self.insurance_count)
--print ("self.insuranceCost: "..self.insuranceCost)

self.memory			[(simulationTime % ROUNDS) + 1] 	= self.floodAction
--------------------------------------------------------------------
--------------------------------------------------------------------
self.insmemory	[(simulationTime % ROUNDS) + 1] = self.purchaseInsuranceCap + self.purchaseInsurance

end -- end of main function
}

householders = Society{instance = Householder, quantity = 5000}


logFile = io.open("c:\\Users\\Linda\\Model_pt_281215_redo.csv", "w+") 
--logFile:write("time\thh\tcap\trr\tnoth\tplpp\n")
logFile:write("time\tins\texp\tsavings\n")

t = Timer{
	Event{time = 0, 	action = function(event)
		
		simulationTime = event:getTime()
		householders:execute( )
		
		forEachAgent( householders, function(ag)
			
			local line = ""	
--[[			
			line = line..simulationTime.."\t"
			line = line..ag.p_buy_plpp.."\t"
			line = line..ag.p_buy_ins_cap.."\t"
			line = line..ag.p_buy_ins_rr.."\t"
			line = line..ag.p_buy_noth.."\n"
]]--	
			line = line..simulationTime.."\t"
			line = line..ag.rp_ins_count.."\t"
			line = line..(ag.rp_exp_count-1).."\t"
			line = line..ag.rp_savings_count.."\n"
			
			
			--line = line..ag.hh_bracket.."\t"
			--line = line..ag.purchaseInsuranceCap.."\t"
			--line = line..ag.purchaseInsurance.."\t"
			--line = line..ag.purchaseNothing.."\t"
			--line = line..ag.purchasePlpp.."\n"
			
		    io.flush()
		
			logFile:write(line)

			
		end)
		
	FLOODS_PROB = FLOODS_PROB + FLOODS_PROB_INCREMENT	
	
		
	end}
}

t:execute(ROUNDS)

logFile:close()
print("READY")
print("Pretty please, press <ENTER> to quit.")
