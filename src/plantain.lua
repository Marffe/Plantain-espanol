SMODS.Atlas {
  key = 'plantain',
  path = 'plantain.png',
  px = 71,
  py = 95
}

SMODS.Atlas{
  key = "modicon",
  path = "modicon.png",
  px = 34,
  py = 34
}

SMODS.current_mod.extra_tabs = function()
  local scale = 0.5
  return {
      label = "Credits",
      tab_definition_function = function()
      return {
          n = G.UIT.ROOT,
          config = {
          align = "cm",
          padding = 0.05,
          colour = G.C.CLEAR,
          },
          nodes = {
          {
              n = G.UIT.R,
              config = {
              padding = 0,
              align = "cm"
              },
              nodes = {
              {
                  n = G.UIT.T,
                  config = {
                  text = "Programming: IcebergLettuce, NachitoSMO",
                  shadow = false,
                  scale = scale,
                  colour = G.C.GREEN
                  }
              }
              }
          },
          {
              n = G.UIT.R,
              config = {
              padding = 0,
              align = "cm"
              },
              nodes = {
              {
                  n = G.UIT.T,
                  config = {
                  text = "Art: IcebergLettuce",
                  shadow = false,
                  scale = scale,
                  colour = G.C.PURPLE
                  }
              },
              }
          },
          {
              n = G.UIT.R,
              config = {
                  padding = 0,
                  align = "cm"
              },
              nodes = {
                  {
                  n = G.UIT.T,
                  config = {
                      text = "Idea Guys: AtomicLight, BurntFrenchToast, TomatoIcecream",
                      shadow = false,
                      scale = scale,
                      colour = G.C.MONEY
                  }
                  },
              }
          }
          }
      }
      end
  }
end

PlConfig = SMODS.current_mod.config

SMODS.current_mod.config_tab = function() --Config tab
  return {
    n = G.UIT.ROOT,
    config = {
      align = "cm",
      padding = 0.05,
      colour = G.C.CLEAR,
    },
    nodes = {
      create_toggle({
          label = "Wave 2 (EXPERIMENTAL)",
          ref_table = PlConfig,
          ref_value = "wave2",
      })
    },
  }
end

SMODS.Joker {
  key = 'postcard',
  loc_txt = {
    name = 'Postcard',
    text = {
      "Gains {X:mult,C:white}X1{} Mult for",
      "each {C:attention}Postcard{}",
      "sold this run",
      "{C:inactive}(Currently {X:mult,C:white} X#1# {C:inactive} Mult)",
    }
  },
  rarity = 1,
  atlas = 'plantain',
  blueprint_compat = true,
  eternal_compat = false,
  pos = { x = 0, y = 0 },
  cost = 4,
  config = { extra = { Xmult = 1 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.Xmult + (G.GAME.plantain_postcards_sold or 0) } }
  end,
  calculate = function(self, card, context)
    if context.selling_self then
      G.GAME.plantain_postcards_sold = (G.GAME.plantain_postcards_sold or 0) + 1
    end
    if context.joker_main and context.cardarea == G.jokers then
      if G.GAME.plantain_postcards_sold ~= nil then
        return {
          Xmult_mod = card.ability.extra.Xmult + G.GAME.plantain_postcards_sold,
          message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult + G.GAME.plantain_postcards_sold } }
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'jim',
  loc_txt = {
    name = 'Jim',
    text = {
      "Retrigger all played",
      "cards {C:attention}without",
      "enhancements"
    }
  },
  rarity = 1,
  atlas = 'plantain',
  blueprint_compat = true,
  pos = { x = 1, y = 0 },
  cost = 4,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.repetition then
      if context.other_card.ability.set ~= 'Enhanced' then
        return 
        {
          message = localize("k_again_ex"),
          repetitions = 1,
          card = card, 
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'bingo_card',
  loc_txt = {
    name = 'Bingo Card',
    text = {
      "Each played {C:attention}#1#{} and {C:attention}#2#{}",
      "gives {C:chips}+#3#{} Chips and {C:mult}+#4#{} Mult",
      "when scored, number cards",
      "change every round"
    }
  },
  rarity = 1,
  atlas = 'plantain',
  blueprint_compat = true,
  pos = { x = 2, y = 0 },
  cost = 4,
  config = { extra = { mult = 7, chips = 25, bingo1 = 3, bingo2 = 7 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.bingo1, card.ability.extra.bingo2, card.ability.extra.chips, card.ability.extra.mult } }
  end,
  set_ability = function(self, card, initial, delay_sprites)
    local numbers = {2, 3, 4, 5, 6, 7, 8, 9, 10}
    local bingo1 = pseudorandom_element(numbers, pseudoseed('bingo'..G.GAME.round_resets.ante))
    table.remove(numbers, bingo1 - 1)
    local bingo2 = pseudorandom_element(numbers, pseudoseed('bango'..G.GAME.round_resets.ante))
    if bingo1 > bingo2 then
      bingo1, bingo2 = bingo2, bingo1
    end
    card.ability.extra.bingo1 = bingo1
    card.ability.extra.bingo2 = bingo2
	end,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
      -- :get_id tests for the rank of the card. Other than 2-10, Jack is 11, Queen is 12, King is 13, and Ace is 14.
      if context.other_card:get_id() == card.ability.extra.bingo1 or context.other_card:get_id() == card.ability.extra.bingo2 then
        -- Specifically returning to context.other_card is fine with multiple values in a single return value, chips/mult are different from chip_mod and mult_mod, and automatically come with a message which plays in order of return.
        return {
          chips = card.ability.extra.chips,
          mult = card.ability.extra.mult,
          card = context.other_card
        }
      end
    end
    if context.end_of_round and not context.repetition and not context.individual then
      card:set_ability(self, card, nil, nil)
    end
  end
}

if PlConfig.wave2 then --gay baby jail

--portal to hell
SMODS.Joker {
  key = 'inkblot_joker',
  loc_txt = {
    name = 'Inkblot',
    text = {
      "Mimics a random {C:attention}Joker",
      "every round",
      "{C:inactive}Currently #1#"
    }
  },
  rarity = 1,
  atlas = 'plantain',
  blueprint_compat = false,
  pos = { x = 3, y = 0 },
  cost = 3,
  set_ability = function(self, card, initial, delay_sprites)
    if G.jokers and not G.SETTINGS.paused then
      local function deepcopy(tbl)
        local copy = {}
        for k, v in pairs(tbl) do
          if type(v) == "table" then
            copy[k] = deepcopy(v)
          else
            copy[k] = v
          end
        end
        return copy
      end
      
      local options = {}

      for k, v in pairs(G.P_CENTERS) do
        if v.key ~= 'j_Plantain_inkblot_joker' and v.set == 'Joker' and v.unlocked and v.name ~= 'Shortcut' and v.name ~= 'Four Fingers'
        and (not v.mod or (v.mod and v.mod.id == 'plantain')) then
          options[k] = v
        end
      end

      local chosen_key = pseudorandom_element(options, pseudoseed('inkblot_joker'))
      if chosen_key then
        card.added_to_deck = false
        card.plan_calc_2 = nil
        card.plan_loc_vars_2 = nil
        card.calc_dollar_bonus = nil
        card.plan_set_ability_2 = nil
        
        local car = SMODS.create_card({set = 'Joker', key = chosen_key.key, no_edition = true})

        card.ability = nil
        card.ability = deepcopy(car.ability)
        card.ability.mim_key = chosen_key.key
        G.jokers:remove_card(car)
        car:remove()
        car = nil
        
        card:add_to_deck()
        card.added_to_deck = true

        if G.P_CENTERS[chosen_key.key].calculate then
          card.plan_calc_2 = G.P_CENTERS[chosen_key.key].calculate
        end

        if G.P_CENTERS[chosen_key.key].loc_vars then
          card.plan_loc_vars_2 = G.P_CENTERS[chosen_key.key].loc_vars
        end

        if G.P_CENTERS[chosen_key.key].calc_dollar_bonus then
          card.calc_dollar_bonus = G.P_CENTERS[chosen_key.key].calc_dollar_bonus
        end

        if G.P_CENTERS[chosen_key.key].set_ability then
          card.plan_set_ability_2 = G.P_CENTERS[chosen_key.key].set_ability
        end

        if card.ability.name == "Invisible Joker" then 
          card.ability.invis_rounds = 0
        end
        if card.ability.name == 'To Do List' then
          local _poker_hands = {}
          for k, v in pairs(G.GAME.hands) do
              if v.visible then _poker_hands[#_poker_hands+1] = k end
          end
          local old_hand = card.ability.to_do_poker_hand
          card.ability.to_do_poker_hand = nil
  
          while not card.ability.to_do_poker_hand do
            card.ability.to_do_poker_hand = pseudorandom_element(_poker_hands, pseudoseed((card.area and card.area.config.type == 'title') and 'false_to_do' or 'to_do'))
              if card.ability.to_do_poker_hand == old_hand then card.ability.to_do_poker_hand = nil end
          end
        end
        if card.ability.name == 'Caino' then 
          card.ability.caino_xmult = 1
        end
        if card.ability.name == 'Yorick' then 
          card.ability.yorick_discards = card.ability.extra.discards
        end
        if card.ability.name == 'Loyalty Card' then 
          card.ability.burnt_hand = 0
          card.ability.loyalty_remaining = card.ability.extra.every
        end
  
        card.base_cost = card.config.center.cost or 1
  
        card.ability.hands_played_at_create = G.GAME and G.GAME.hands_played or 0
      end
    end
	end,
  loc_vars = function(self, info_queue, card)
    if card.ability.mim_key then
      if card.config.center.mod and card.plan_loc_vars_2 and type(card.ability.extra) == 'table' then
        local specific = card:plan_loc_vars_2(info_queue, card).vars
        info_queue[#info_queue+1] = {type = 'descriptions', set = 'Joker', key = card.ability.mim_key, specific_vars = specific or {}}
      else
        info_queue[#info_queue+1] = {type = 'descriptions', set = 'Joker', key = card.ability.mim_key, specific_vars = card.plantain_info or {}}
      end
      return { vars = {localize{type = 'name_text', set = 'Joker', key = card.ability.mim_key}} }
    else
      return { vars = {"none"}}
    end
  end,
  calculate = function(self, card, context)
    if context.pl_cash_out and not card.getting_sliced and not context.repetition and not context.individual and not context.blueprint then
      card:set_ability(self, card, nil, nil)
      if card.plan_set_ability_2 then
        card.plan_set_ability_2(self, card, nil, nil)
      end
      return card_eval_status_text(card, 'jokers', nil, nil, nil, {message = 'Updated!', colour = G.C.MONEY})
    end
    if card.plan_calc_2 then
      local mim_calc = card.plan_calc_2(self, card, context)
      return mim_calc
    end
  end
}

end

SMODS.Joker {
  key = 'apple_pie',
  loc_txt = {
    name = 'Apple Pie',
    text = {
      'Earn {C:money}$#1#{} at end of round,',
      'and decrease by {C:money}$#2#{}'
    }
  },

  config = { extra = { money = 8, money_loss = 1 } },
  rarity = 1,
  atlas = 'plantain',
  blueprint_compat = false,
  pos = { x = 4, y = 0 },
  cost = 6,

  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.money, card.ability.extra.money_loss } }
  end,

  calc_dollar_bonus = function(self, card)
    local bonus = card.ability.extra.money
    if bonus > 0 then return bonus end
  end,

  calculate = function(self, card, context)
    if context.pl_cash_out and not context.blueprint then
      card.ability.extra.money = card.ability.extra.money - card.ability.extra.money_loss
      if card.ability.extra.money == 0 then
        card_eval_status_text(card, 'jokers', nil, nil, nil, {message = 'Sold Out!', colour = G.C.MONEY})
        G.E_MANAGER:add_event(Event({
          func = function()
              play_sound('tarot1')
              card.T.r = -0.2
              card:juice_up(0.3, 0.4)
              card.states.drag.is = true
              card.children.center.pinch.x = true
              G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                  func = function()
                          G.jokers:remove_card(card)
                          card:remove()
                          card = nil
                      return true; end})) 
              return true
          end
      }))
      else
        card_eval_status_text(card, 'jokers', nil, nil, nil, {message = 'Slice!', colour = G.C.MONEY})
     end
    end
  end
}

SMODS.Joker {
  key = 'grape_soda',
  loc_txt = {
    name = 'Grape Soda',
    text = {
      "After {C:attention}skipping{} a",
      "{C:attention}Small Blind{} or {C:attention}Big Blind{},",
      "return to that {C:attention}Blind"
    }
  },
  rarity = 2,
  atlas = 'plantain',
  config = { extra = { should_destroy = true } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.should_destroy } }
  end,
  blueprint_compat = false,
  pos = { x = 0, y = 1 },
  cost = 6,
  calculate = function(self, card, context)
    if context.skip_blind then
      G.E_MANAGER:add_event(Event({
        func = function()
          for i=1, #G.jokers.cards do
            other_soda = G.jokers.cards[i]
            if other_soda.ability.name == card.ability.name and other_soda ~= card and card.ability.extra.should_destroy then
              other_soda.ability.extra.should_destroy = false
            end
          end
          if card.ability.extra.should_destroy then
            card_eval_status_text(card, 'jokers', nil, nil, nil, {message = 'Skipped!', colour = G.C.RED})
            if G.GAME.blind_on_deck == 'Big' then
              G.GAME.blind_on_deck = 'Small'
              G.GAME.round_resets.blind_states.Small = 'Current'
              G.GAME.round_resets.blind_states.Big = 'Upcoming'
            end

            if G.GAME.blind_on_deck == 'Boss' then
              G.GAME.blind_on_deck = 'Big'
              G.GAME.round_resets.blind_states.Big = 'Current'
              G.GAME.round_resets.blind_states.Boss = 'Upcoming'
            end

            G.blind_select_opts[string.lower(G.GAME.blind_on_deck)].children.alert = nil --removes "Skipped" text
            card:start_dissolve({G.C.RED}, card)
            play_sound('whoosh2')
          end
        return true
      end}))
    end
  end
}

SMODS.Joker {
  key = 'matryoshka',
  loc_txt = {
    name = 'Matryoshka',
    text = {
      'Retrigger all scoring',
      'cards if played hand',
      'contains a {C:attention}Straight'
    }
  },
  config = { extra = { repetitions = 1 } },
  rarity = 2,
  atlas = 'plantain',
  blueprint_compat = true,
  pos = { x = 1, y = 1 },
  cost = 6,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.repetition and not context.repetition_only then
      if next(context.poker_hands['Straight']) then
        return {
          message = 'Yeshcho Raz!',
          repetitions = card.ability.extra.repetitions,
          card = card,
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'mini_crossword',
  loc_txt = {
    name = 'Mini Crossword',
    text = {
      'Gains {C:mult}+#1#{} Mult if played hand',
      'has exactly {C:attention}#2#{} cards, chooses',
      'between 3, 4, or 5 every round',
      '{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)'
    }
  },
  rarity = 2,
  atlas = 'plantain',
  cost = 6,
  blueprint_compat = true,
  pos = { x = 2, y = 1 },
  config = { extra = { mult_mod = 2, cw_size = 1 , mult = 0} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult_mod, card.ability.extra.cw_size, card.ability.extra.mult} }
  end,
  set_ability = function(self, card, initial, delay_sprites)
    local valid_cw_size = {3, 4, 5}
    card.ability.extra.cw_size = pseudorandom_element(valid_cw_size, pseudoseed('among_ass'..G.GAME.round_resets.ante)) 
	end,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before and #context.full_hand == card.ability.extra.cw_size and not context.blueprint then
      card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
      return { message = localize('k_upgrade_ex'), focus = card, colour = G.C.MULT}
    end
    if context.joker_main and context.cardarea == G.jokers then
      return {
        mult_mod = card.ability.extra.mult,
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
      }
    end
    if context.end_of_round and not context.repetition and not context.individual then
      card:set_ability(self, card, nil, nil)
    end
  end
}



SMODS.Joker {
  key = 'diamond_joker',
  loc_txt = {
    name = 'Diamond Joker',
    text = {
      "Gains {X:mult,C:white}X#1#{} Mult each time",
      "a {C:attention}Stone{} card scores, destroy",
      "all played {C:attention}Stone{} cards",
      "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)"
    }
  },
  rarity = 2,
  atlas = 'plantain',
  config = { extra = { xmult_mod = 0.5, xmult = 1 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult_mod, card.ability.extra.xmult } }
  end,
  blueprint_compat = true,
  pos = { x = 3, y = 1 },
  cost = 6,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.other_card and context.other_card.ability.effect == 'Stone Card' and context.individual then
      card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
      return { message = localize('k_upgrade_ex'), focus = card, colour = G.C.MULT}
    end
    if context.destroying_card and context.destroying_card.ability.effect == 'Stone Card' then
      G.E_MANAGER:add_event(Event({
        func = function()
          context.destroying_card:start_dissolve({G.C.GOLD}, context.destroying_card)
          play_sound('whoosh2')
        return true
      end}))
      return true
    end
    if context.joker_main and context.cardarea == G.jokers then
      return {
        Xmult_mod = card.ability.extra.xmult,
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } }
      }
    end
  end
}

SMODS.Joker {
  key = 'el_dorado',
  loc_txt = {
    name = 'El Dorado',
    text = {
      'Earn {C:money}$#1#{} for each {C:attention}Wild',
      'card in your {C:attention}full deck',
      'at end of round',
      '{C:inactive}(Currently {C:money}$#2#{C:inactive})'
    }
  },

  config = { extra = { money_mod = 3, wild_tally = 0} },
  rarity = 2,
  atlas = 'plantain',
  blueprint_compat = false,
  pos = { x = 4, y = 1 },
  cost = 6,

  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.money_mod, card.ability.extra.wild_tally } }
  end,

  calc_dollar_bonus = function(self, card)
    local bonus = card.ability.extra.wild_tally
    if bonus > 0 then return bonus end
  end
}

local card_updateref = Card.update
function Card.update(self, dt)
  if G.STAGE == G.STAGES.RUN then
    if self.ability.name == 'j_Plantain_el_dorado' then 
      self.ability.extra.wild_tally = 0
      for k, v in pairs(G.playing_cards) do
        if v.config.center == G.P_CENTERS.m_wild then self.ability.extra.wild_tally = self.ability.extra.wild_tally+self.ability.extra.money_mod end
      end
    end
  end
  card_updateref(self, dt)
end

SMODS.Joker {
  key = 'black_cat',
  loc_txt = {
    name = 'Black Cat',
    text = {
      'Gains {C:chips}+#1#{} Chips each',
      'time a {C:attention}Lucky{} card',
      '{C:attention}fails{} to trigger',
      '{C:inactive}(Currently {C:chips}+#2# {C:inactive}Chips)'
    }
  },
  rarity = 3,
  atlas = 'plantain',
  blueprint_compat = true,
  config = { extra = { chips_mod = 13, chips = 0 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.chips_mod , card.ability.extra.chips } }
  end,
  pos = { x = 0, y = 2 },
  cost = 8,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.individual and not context.blueprint then
      if context.other_card.ability.effect == "Lucky Card" and not context.other_card.lucky_trigger then
        card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
        return { message = localize('k_upgrade_ex'), focus = card}
      end
    end

    if context.joker_main and context.cardarea == G.jokers then
      if card.ability.extra.chips > 0 then
        return 
        {
          chip_mod = card.ability.extra.chips,
          message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } }
        }
      end
    end
  end
}



--TODO: fix the sound effect
SMODS.Joker {
  key = 'mossy_joker',
  loc_txt = {
    name = 'Mossy Joker',
    text = {
      "Convert a random card",
      "{C:attention}held in hand{} into a",
      "random {C:attention}scored{} card"
    }
  },
  rarity = 3,
  atlas = 'plantain',
  blueprint_compat = true,
  pos = { x = 1, y = 2 },
  cost = 7,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before and #G.hand.cards > 0 then
      local removed_card = pseudorandom_element(G.hand.cards, pseudoseed('mossy_joker'))
      local copied_card = pseudorandom_element(context.scoring_hand, pseudoseed('mossy_joker'))
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() removed_card:flip();play_sound('tarot1');removed_card:juice_up(0.3, 0.3);return true end }))
      delay(0.2)
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        copy_card(copied_card, removed_card)
        return true end }))
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() removed_card:flip();removed_card:juice_up(0.3, 0.3);return true end }))
      delay(0.5)
      return {
            message = localize('k_copied_ex'),
            colour = G.C.GREEN,
            card = card,
          }
    end
  end
}

SMODS.Joker {
  key = 'nametag',
  loc_txt = {
    name = 'Nametag',
    text = {
      "{X:mult,C:white}X2{} Mult for every",
      "{C:attention}Joker{} with \"Joker\"",
      "in its name"
    }
  },
  rarity = 3,
  atlas = 'plantain',
  blueprint_compat = true,
  pos = { x = 2, y = 2 },
  cost = 7,
  config = { extra = { Xmult = 2 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.Xmult } }
  end,
  calculate = function(self, card, context)
    if context.other_joker and (string.find(context.other_joker.ability.name, 'Joker')
    or string.find(context.other_joker.ability.name, 'joker')) then
      G.E_MANAGER:add_event(Event({
        func = function()
            context.other_joker:juice_up(0.5, 0.5)
            return true
        end
    })) 
    return {
        message = localize{type = 'variable',key = 'a_xmult', vars = { card.ability.extra.Xmult } },
        Xmult_mod = card.ability.extra.Xmult,
        focus = context.other_joker
    }
    end
  end
}

SMODS.Joker {
  key = 'calculator',
  loc_txt = {
    name = 'Calculator',
    text = {
      "Add {C:attention}50%{} of {C:mult}Mult",
      "to {C:chips}Chips"
    }
  },
  rarity = 3,
  atlas = 'plantain',
  blueprint_compat = true,
  pos = { x = 3, y = 2 },
  cost = 8,
  calculate = function(self, card, context)
    if context.joker_main and context.cardarea == G.jokers then
      local chip_mod = math.ceil(mult * 0.5)
      return 
      {
        message = localize{type='variable',key='a_chips',vars={chip_mod}},
        chip_mod = chip_mod,
        colour = G.C.CHIPS
      }
    end
  end
}

SMODS.Joker {
  key = 'raw_meat',
  loc_txt = {
    name = 'Raw Meat',
    text = {
      "After defeating {C:attention}Boss Blind{},",
      "{C:attention}-1{} Ante and destroy all",
      "{C:attention}Raw Meat Jokers{}"
    }
  },
  rarity = 3,
  atlas = 'plantain',
  blueprint_compat = false,
  config = { extra = { minus_ante = -1, reduce_ante = true } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.minus_ante, card.ability.extra.reduce_ante } }
  end,
  pos = { x = 4, y = 2 },
  cost = 8,
  calculate = function(self, card, context)
    if context.end_of_round and G.GAME.blind.boss and not context.repetition and not context.individual then
      G.E_MANAGER:add_event(Event({
        func = function()
          local other_meat = nil
          for i=1, #G.jokers.cards do
            other_meat = G.jokers.cards[i]
            if other_meat.ability.name == card.ability.name and other_meat ~= card and card.ability.extra.reduce_ante then
              other_meat.ability.extra.reduce_ante = false
            end
          end
          if card.ability.extra.reduce_ante then
            ease_ante(card.ability.extra.minus_ante)
            card_eval_status_text(card, 'jokers', nil, nil, nil, {message = 'Ante Down', colour = G.C.BLACK})
          end
          G.E_MANAGER:add_event(Event({
            func = function()
              if card.ability.extra.reduce_ante then --avoids duping the sound effect
                play_sound('whoosh2')
              end
              card:start_dissolve({G.C.BLACK}, card)
              return true
            end}))
          return true;
        end}))
    end
  end
}