function PL_UTIL.add_booster_pack()
  if not G.shop then return end
  local pack_watch = {
    'p_arcana_normal_1',
    'p_arcana_normal_2',
    'p_arcana_normal_3',
    'p_arcana_normal_4',
    'p_arcana_jumbo_1',
    'p_arcana_jumbo_2',
    'p_arcana_mega_1',
    'p_arcana_mega_2',
    'p_celestial_normal_1',
    'p_celestial_normal_2',
    'p_celestial_normal_3',
    'p_celestial_normal_4',
    'p_celestial_jumbo_1',
    'p_celestial_jumbo_2',
    'p_celestial_mega_1',
    'p_celestial_mega_2',
    'p_standard_normal_1',
    'p_standard_normal_2',
    'p_standard_normal_3',
    'p_standard_normal_4',
    'p_standard_jumbo_1',
    'p_standard_jumbo_2',
    'p_standard_mega_1',
    'p_standard_mega_2',
    'p_spectral_normal_1',
    'p_spectral_normal_2',
    'p_spectral_jumbo_1',
    'p_spectral_mega_1',
    'p_buffoon_normal_1',
    'p_buffoon_normal_2',
    'p_buffoon_jumbo_1',
    'p_buffoon_mega_1',
  }
  local pack_chosen = pack_watch[ math.random( #pack_watch ) ]
  -- Create the pack the same way vanilla game does it
  local pack = Card(
    G.shop_booster.T.x + G.shop_booster.T.w / 2,
    G.shop_booster.T.y,
    G.CARD_W * 1.27, G.CARD_H * 1.27,
    G.P_CARDS.empty,
    G.P_CENTERS[pack_chosen],
    { bypass_discovery_center = true, bypass_discovery_ui = true }
  )

  if price then
    pack.cost = price
  end

  -- Create the price tag above the pack
  create_shop_card_ui(pack, 'Booster', G.shop_booster)

  -- Add the pack to the shop
  pack:start_materialize()
  G.shop_booster:emplace(pack)
end