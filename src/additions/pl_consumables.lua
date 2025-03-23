SMODS.Consumable{
	set = 'Spectral',
	key = 'spec_aether', 
    atlas = 'pl_atlas_consumables',
	pos = { x = 0, y = 0 },

	config = {extra = {count = 4, cost = 8}},
	--discovered = true,

	loc_vars = function(self, info_queue, card)

	end,

	can_use = function(self, card)
		
	end,

	use = function(self, card)
		
	end,
}

SMODS.Consumable{
	set = 'Spectral',
	key = 'spec_rebirth',
    atlas = 'pl_atlas_consumables',
	pos = { x = 0, y = 0 },

	config = {extra = {cost = 4}},
	discovered = true,

	can_use = function(self, card)
		if #G.hand.highlighted == 3 then
			return true
		else
			return false
		end
	end,

	use = function(self, card)
		local destroyed_card = nil
		for i=1, #G.hand.highlighted do
			if (i ~= 2) then
				local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
           		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.5, func = function() 
					G.hand.highlighted[i]:flip();
					play_sound('tarot2', percent, 0.6);
					G.hand.highlighted[i]:juice_up(0.3, 0.3);
				return true end }))
			else
				destroyed_card = G.hand.highlighted[i]
			end
		end
		for i=1, #G.hand.highlighted do
			if (i ~= 2) then
				
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.5,func = function()
					local suit_prefix = string.sub(G.hand.highlighted[i].base.suit, 1, 1)..'_'
                	local rank_suffix = G.hand.highlighted[2].base.id < 10 and tostring(G.hand.highlighted[2].base.id) or
										G.hand.highlighted[2].base.id == 10 and 'T' or G.hand.highlighted[2].base.id == 11 and 'J' or
										G.hand.highlighted[2].base.id == 12 and 'Q' or G.hand.highlighted[2].base.id == 13 and 'K' or
										G.hand.highlighted[2].base.id == 14 and 'A'
					G.hand.highlighted[i]:set_base(G.P_CARDS[suit_prefix..rank_suffix])
					G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);
					G.hand.highlighted[i]:juice_up(0.3, 0.3);
					return true end }))
			end
		end

		G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function() 
				if SMODS.shatters(destroyed_card) then
					destroyed_card:shatter()
				else
					destroyed_card:start_dissolve(nil, destroyed_card)
				end
		return true end }))
	end,
}