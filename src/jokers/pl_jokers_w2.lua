SMODS.Joker {
  key = 'quarry',
  loc_txt = {
    name = 'Quarry',
    text = {
      "Gains {X:mult,C:white}X#1#{} Mult each time",
      "a {C:attention}Stone{} card scores, destroy",
      "all played {C:attention}Stone{} cards",
      "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)"
    }
  },
  rarity = 2,
  atlas = 'pl_atlas_w2',
  discovered = true,
  config = { extra = { xmult_mod = 0.5, xmult = 1 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult_mod, card.ability.extra.xmult } }
  end,
  blueprint_compat = true,
  pos = { x = 0, y = 0 },
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
