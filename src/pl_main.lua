SMODS.Atlas {
  key = 'pl_atlas_w1',
  path = 'pl_atlas_w1.png',
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = 'pl_atlas_w2',
  path = 'pl_atlas_w2.png',
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

pl_config = SMODS.current_mod.config

SMODS.current_mod.config_tab = function()
  return {
    n = G.UIT.ROOT,
    config = {
      align = "cm",
      padding = 0.05,
      colour = G.C.CLEAR,
    },
    nodes = {
      create_toggle({
          label = "Wave 2 (Experimental, requires reset!)",
          ref_table = pl_config,
          ref_value = "wave2",
      })
    },
  }
end

NFS.load(SMODS.current_mod.path .. 'src/jokers/pl_jokers_w1.lua')()

if pl_config.wave2 then
  NFS.load(SMODS.current_mod.path .. 'src/jokers/pl_jokers_w2.lua')()
end