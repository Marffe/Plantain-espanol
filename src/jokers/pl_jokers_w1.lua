SMODS.Joker {
  key = 'plantain',
  loc_txt = {
    name = 'Plantain',
    text = {
      'Gains {C:chips}+#1#{} Chips at end',
      'of round, {C:green}#2# in #3#{} chance',
      'this card is destroyed',
      '{C:inactive}(Currently {C:chips}+#4#{C:inactive} Chips)'
    }
  },

  config = { extra = { chips_mod = 20, chance = 6} },
  rarity = 1,
  atlas = 'pl_atlas_w1',
  blueprint_compat = true,
  eternal_compat = false,
  perishable_compat = true,
  pos = { x = 0, y = 0 },
  cost = 5,
  discovered = true,

  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.chips_mod, (G.GAME.probabilities.normal or 1), card.ability.extra.chance, (G.GAME.pl_plantain_chips or card.ability.extra.chips_mod) } }
  end,

  calculate = function(self, card, context)
    if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
      if pseudorandom('plantain') < G.GAME.probabilities.normal/card.ability.extra.chance then 
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card.T.r = -0.2
                card:juice_up(0.3, 0.4)
                card.states.drag.is = true
                card.children.center.pinch.x = true
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                            G.jokers:remove_card(self)
                            card:remove()
                            card = nil
                        return true; end})) 
                return true
            end
        })) 
        return {
            message = 'Cooked!'
        }
      else
        G.GAME.pl_plantain_chips = (G.GAME.pl_plantain_chips or card.ability.extra.chips_mod) + card.ability.extra.chips_mod
        return {
            message = localize('k_upgrade_ex')
        }
      end
    end
    if context.joker_main and context.cardarea == G.jokers then
      local potatochips = (G.GAME.pl_plantain_chips or card.ability.extra.chips_mod)
      return 
      {
        chip_mod = potatochips,
        message = localize { type = 'variable', key = 'a_chips', vars = { potatochips } }
      }
    end
  end
}

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
  atlas = 'pl_atlas_w1',
  blueprint_compat = true,
  eternal_compat = false,
  perishable_compat = true,
  pos = { x = 1, y = 0 },
  cost = 4,
  discovered = true,
  config = { extra = { Xmult = 1 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.Xmult + (G.GAME.pl_postcards_sold or 0) } }
  end,
  calculate = function(self, card, context)
    if context.selling_self then
      G.GAME.pl_postcards_sold = (G.GAME.pl_postcards_sold or 0) + 1
    end
    if context.joker_main and context.cardarea == G.jokers then
      if G.GAME.pl_postcards_sold ~= nil then
        return {
          Xmult_mod = card.ability.extra.Xmult + G.GAME.pl_postcards_sold,
          message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult + G.GAME.pl_postcards_sold } }
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
  config = { extra = { repetitions = 1 } },
  rarity = 1,
  atlas = 'pl_atlas_w1',
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  pos = { x = 2, y = 0 },
  cost = 6,
  discovered = true,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.repetition then
      if context.other_card.ability.set ~= 'Enhanced' then
        return 
        {
          message = localize("k_again_ex"),
          repetitions = card.ability.extra.repetitions,
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
  atlas = 'pl_atlas_w1',
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  pos = { x = 3, y = 0 },
  cost = 5,
  discovered = true,
  config = { extra = { mult = 5, chips = 25, bingo1 = 3, bingo2 = 7 } },
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
      if context.other_card:get_id() == card.ability.extra.bingo1 or context.other_card:get_id() == card.ability.extra.bingo2 then
        return {
          chips = card.ability.extra.chips,
          mult = card.ability.extra.mult,
          card = card
        }
      end
    end
    if context.end_of_round and not context.repetition and not context.individual then
      card:set_ability(self, card, nil, nil)
    end
  end
}

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
  atlas = 'pl_atlas_w1',
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
  pos = { x = 4, y = 0 },
  cost = 6,
  discovered = true,

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
        G.E_MANAGER:add_event(Event({
          func = function()
              play_sound('tarot1')
              card.T.r = -0.2
              card:juice_up(0.3, 0.4)
              card.states.drag.is = true
              card.children.center.pinch.x = true
              G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                  func = function()
                          G.jokers:remove_card(self)
                          card:remove()
                          card = nil
                      return true; end})) 
              return true
          end
        })) 
        card_eval_status_text(card, 'jokers', nil, nil, nil, {message = 'Sold Out!', colour = G.C.MONEY})
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
      "return to that {C:attention}Blind{} and",
      "destroy this card"
    }
  },
  rarity = 2,
  atlas = 'pl_atlas_w1',
  config = { extra = { should_destroy = true } },
  discovered = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.should_destroy } }
  end,
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
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
    if context.setting_blind then
      card.ability.extra.should_destroy = true
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
  atlas = 'pl_atlas_w1',
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  pos = { x = 1, y = 1 },
  cost = 6,
  discovered = true,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.repetition and not context.repetition_only then
      if next(context.poker_hands['Straight']) then
        return {
          message = localize("k_again_ex"),
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
      'has exactly {C:attention}#2#{} cards',
      '{s:0.8}Chooses between 3, 4, or 5 every round',
      '{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)'
    }
  },
  rarity = 2,
  atlas = 'pl_atlas_w1',
  cost = 6,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  pos = { x = 2, y = 1 },
  config = { extra = { mult_mod = 2, cw_size = 1 , mult = 0} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult_mod, card.ability.extra.cw_size, card.ability.extra.mult} }
  end,
  set_ability = function(self, card, initial, delay_sprites)
    local valid_cw_size = {3, 4, 5}
    card.ability.extra.cw_size = pseudorandom_element(valid_cw_size, pseudoseed('crossword'..G.GAME.round_resets.ante)) 
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
      local valid_cw_size = {3, 4, 5}
      table.remove(valid_cw_size, card.ability.extra.cw_size - 2)
      card.ability.extra.cw_size = pseudorandom_element(valid_cw_size, pseudoseed('crossword'..G.GAME.round_resets.ante)) 
    end
  end
}



SMODS.Joker {
  key = 'crystal_joker',
  loc_txt = {
    name = 'Crystal Joker',
    text = {
      "If played hand contains",
      "a {C:attention}Stone{} card, create",
      "a random {C:tarot}Tarot{} card"
    }
  },
  rarity = 2,
  atlas = 'pl_atlas_w1',
  discovered = true,
  config = { extra = { stone_played = false} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.stone_played} }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  pos = { x = 3, y = 1 },
  cost = 6,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.individual then
      if context.other_card.ability.effect == "Stone Card" and not context.other_card.lucky_trigger then
        card.ability.extra.stone_played = true
      end
    end

    if context.before and context.cardarea == G.jokers then
      local stone = false
      for i = 1, #context.scoring_hand do
        if context.scoring_hand[i].ability.effect == "Stone Card" then stone = true end
      end
        if stone then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = (function()
                        local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'crystal')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                        card:juice_up(0.5, 0.5)
                        return true
                    end)}))
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
                  end
            
        
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
  discovered = true,
  atlas = 'pl_atlas_w1',
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  pos = { x = 4, y = 1 },
  cost = 7,

  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.money_mod, card.ability.extra.wild_tally } }
  end,

  calc_dollar_bonus = function(self, card)
    local bonus = card.ability.extra.wild_tally
    if bonus > 0 then return bonus end
  end
}

local card_updateref = Card.update --counts wild cards for el dorado or smth idk
function Card.update(self, dt)
  if G.STAGE == G.STAGES.RUN then
    if self.ability.name == 'j_Plantain_el_dorado' then 
      self.ability.extra.wild_tally = 0
      for k, v in pairs(G.playing_cards) do
        if v.config.center == G.P_CENTERS.m_wild then self.ability.extra.wild_tally = self.ability.extra.wild_tally + self.ability.extra.money_mod end
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
  atlas = 'pl_atlas_w1',
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
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
  atlas = 'pl_atlas_w1',
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
  atlas = 'pl_atlas_w1',
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  pos = { x = 2, y = 2 },
  cost = 8,
  discovered = true,
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
      'Each played card with',
      '{C:attention}#1#{} rank gives',
      '{X:mult,C:white}X#3#{} Mult when scored',
      '{s:0.8}Changes to #2# next round'
    }
  },
  rarity = 3,
  atlas = 'pl_atlas_w1',
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  pos = { x = 3, y = 2 },
  cost = 8,
  discovered = true,
  config = { extra = { is_odd = 'even', next_round = 'odd', Xmult = 1.5} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.is_odd, card.ability.extra.next_round, card.ability.extra.Xmult} }
  end,
  calculate = function(self, card, context)
    if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
      card.ability.extra.is_odd, card.ability.extra.next_round = card.ability.extra.next_round, card.ability.extra.is_odd
    end

    if context.cardarea == G.play and context.other_card and context.individual then
      if card.ability.extra.is_odd == 'odd' then
        if ((context.other_card:get_id() <= 10 and context.other_card:get_id() >= 0
        and context.other_card:get_id()%2 == 1) or (context.other_card:get_id() == 14)) then
          return {
            Xmult_mod = card.ability.extra.Xmult,
            message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
            card = context.other_card
          }
        end
      else
        if context.other_card:get_id() <= 10 and context.other_card:get_id() >= 0
        and context.other_card:get_id()%2 == 0 then
          return {
            Xmult_mod = card.ability.extra.Xmult,
            message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
            card = card
          }
        end
      end
    end
  end
}

SMODS.Joker {
  key = 'raw_meat',
  loc_txt = {
    name = 'Raw Meat',
    text = {
      "After defeating {C:attention}Boss Blind{},",
      "sell this Joker to",
      "go back 1 {C:attention}Ante",
      "{C:inactive}(#2#)"
    }
  },
  rarity = 3,
  atlas = 'pl_atlas_w1',
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
  config = { extra = { minus_ante = -1, reduce_ante = "Inactive" } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.minus_ante, card.ability.extra.reduce_ante } }
  end,
  pos = { x = 4, y = 2 },
  cost = 9,
  discovered = true,
  calculate = function(self, card, context)
    if context.end_of_round and G.GAME.blind.boss and not context.repetition and not context.individual and not context.blueprint then
      card.ability.extra.reduce_ante = "Active"
      local eval = function(card) return not card.REMOVED end
      juice_card_until(card, eval, true)
      return {
        message = localize('k_active_ex'),
        colour = G.C.FILTER
      }
    end
    if context.selling_self and not context.blueprint and card.ability.extra.reduce_ante == "Active" then
      ease_ante(card.ability.extra.minus_ante)
      card_eval_status_text(card, 'jokers', nil, nil, nil, {message = 'Ante Down', colour = G.C.BLACK})
    end
  end
}