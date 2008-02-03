import XMonad
import qualified Data.Map as M
import qualified XMonad.Layout.LayoutHints as LayoutHints
import XMonad.Hooks.EwmhDesktops

layouts = LayoutHints.layoutHints (tiled ||| Mirror tiled ||| Full)
  where tiled = Tall nmaster delta ratio
  	nmaster = 1
	ratio = 3/4
	delta = 3/100

fontName :: String
fontName = "genera-jess14"

dmenu_cmd :: String
dmenu_cmd = "exe=`dmenu_path | dmenu -fn " 
	    ++ fontName 
	    ++ "` && eval \"exec $exe\""

myLogHook :: X ()
myLogHook = do ewmhDesktopsLogHook
               return ()

mykeys (XConfig {modMask = modm}) = M.fromList $
   [ ((modm, xK_p), spawn dmenu_cmd) -- %! Launch dmenu
   , ((mod4Mask, xK_F2), spawn "xscreensaver-command -lock") -- %! Start screensaver
   ]


-- border controls...

iGap (dt,db,dl,dr) (t,b,l,r) = (t+dt,b+db,l+dl,r+dr)

addGap desk part start =
    if desk == 0
    then (iGap part $ head start) : tail start
    else (head start) : addGap (desk - 1) part (tail start)

mkGaps = map $ foldl (flip iGap) (0,0,0,0)

gaps = mkGaps $
  [ [ (16,0,0,0)	-- dzen
    , (0,3,0,0)		-- xbattbar
   -- , (0,0,0,24) 	-- pager
    ] ]
main = xmonad $ defaultConfig
    { borderWidth        = 1
    , terminal           = "urxvt"
    , modMask		 = mod4Mask
    --                       t b l r
    , defaultGaps        = gaps -- [(16,3,0,0)]
    , keys		 = (\c -> mykeys c `M.union` keys defaultConfig c) 
    , layoutHook = layouts
    , logHook		 = myLogHook
    }
