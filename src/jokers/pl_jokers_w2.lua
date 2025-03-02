-- COMMONS

--UNCOMMONS

SMODS.Joker {
  key = 'quarry',
  atlas = 'pl_atlas_w2',
  pos = { x = 0, y = 1 },
  
  config = { extra = { xmult_mod = 0.5, xmult = 1 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult_mod, card.ability.extra.xmult } }
  end,

  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  discovered = true,
  enhancement_gate = 'm_stone',

  rarity = 2,
  cost = 6,

  calculate = function(self, card, context)
    if context.cardarea == G.play and context.other_card and context.other_card.ability.effect == 'Stone Card' and context.individual and not context.blueprint then
      card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
      return { message = localize('k_upgrade_ex'), focus = card, colour = G.C.MULT}
    end
    if context.destroying_card and context.destroying_card.ability.effect == 'Stone Card' and not context.blueprint then
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
  key = 'hot_air_balloon',
  atlas = 'pl_atlas_w2',
  pos = { x = 1, y = 1 },
  
  config = { extra = { money = 1, money_mod = 1 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.money, card.ability.extra.money_mod } }
  end,

  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  discovered = true,

  rarity = 2,
  cost = 6,

  calc_dollar_bonus = function(self, card)
    local bonus = card.ability.extra.money
    if bonus > 0 then return bonus end
  end,

  calculate = function(self, card, context)
    if context.using_consumeable and (context.consumeable.ability.set == "Tarot") and not context.blueprint then
      card.ability.extra.money = card.ability.extra.money + card.ability.extra.money_mod
      card_eval_status_text(card, 'jokers', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.PURPLE})
    end
  end
}

--RARES

SMODS.Joker {
  key = 'three_body_problem',
  atlas = 'pl_atlas_w2',
  pos = { x = 0, y = 2 },
  
  config = { extra = { last_hand = 'none' } },
  loc_vars = function(self, info_queue, card)
    return { vars = { (G.GAME.last_hand_played or card.ability.extra.last_hand) } }
  end,

  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  discovered = true,

  rarity = 3,
  cost = 6,

  add_to_deck = function(self,card,context)
    if not (G.GAME.last_hand_played == nil) then
      card.ability.extra.last_hand = G.GAME.last_hand_played
    end
  end,

  calculate = function(self, card, context)
    if context.before and context.cardarea == G.jokers then
      if (context.scoring_name == 'Three of a Kind') and not (card.ability.extra.last_hand == 'none') then
        -- card_eval_status_text(card, 'jokers', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.PURPLE})
        local text,disp_text = card.ability.extra.last_hand
        local old_text, old_disp_text = context.scoring_name
        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_level_up_ex')})
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(text, 'poker_hands'),chips = G.GAME.hands[text].chips, mult = G.GAME.hands[text].mult, level=G.GAME.hands[text].level})
        level_up_hand(context.blueprint_card or card, text, nil, 1)
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(old_text, 'poker_hands'),chips = G.GAME.hands[old_text].chips, mult = G.GAME.hands[old_text].mult, level=G.GAME.hands[old_text].level})
      end
      card.ability.extra.last_hand = context.scoring_name
    end
  end
}
