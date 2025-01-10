SMODS.Atlas {
  key = 'plantain',
  path = 'plantain.png',
  px = 71,
  py = 95
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
  rarity = 2,
  atlas = 'plantain',
  blueprint_compat = true,
  pos = { x = 0, y = 1 },
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
              self.T.r = -0.2
              self:juice_up(0.3, 0.4)
              self.states.drag.is = true
              self.children.center.pinch.x = true
              G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                  func = function()
                          G.jokers:remove_card(self)
                          self:remove()
                          self = nil
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
  key = 'odd_sock',
  loc_txt = {
    name = 'Odd Sock',
    text = {
      'This joker gains {C:mult}+#1#{} Mult',
      'if played hand {C:attention}does not',
      'contain a {C:attention}Pair',
      '{C:inactive}(Currently {C:mult}+#2# {C:inactive}Mult)'
    }
  },
  rarity = 2,
  atlas = 'plantain',
  blueprint_compat = true,
  config = { extra = { mult_mod = 2, mult = 0 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult_mod, card.ability.extra.mult } }
  end,
  pos = { x = 2, y = 1 },
  cost = 10,
  calculate = function(self, card, context)
    if context.joker_main then
      return {
        mult_mod = card.ability.extra.mult,
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
      }
    end

    if context.before and not next(context.poker_hands['Pair']) and not context.blueprint then
      card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
      return {
        message = 'Lonely!',
        colour = G.C.Mult,
        card = card
      }
    end
  end
}

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
    return { vars = { card.ability.extra.chips_mod , card.ability.extra.chips}}
  end,
  pos = { x = 0, y = 2 },
  cost = 10,
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

--TODO: find a way to change the color
SMODS.Joker {
  key = 'calculator',
  loc_txt = {
    name = 'Calculator',
    text = {
      "Swaps {C:chips}Chips{} and {C:mult}Mult{}"
    }
  },
  rarity = 3,
  atlas = 'plantain',
  blueprint_compat = true,
  pos = { x = 0, y = 0 },
  cost = 6,
  calculate = function(self, card, context)
    if context.joker_main and context.cardarea == G.jokers then
      return 
      {
        message = 'Swap!',
        mult_mod = hand_chips - mult,
        chip_mod = mult - hand_chips
      }
    end
  end
}