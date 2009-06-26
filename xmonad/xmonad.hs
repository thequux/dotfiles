import XMonad
import qualified Data.Map as M
import qualified XMonad.Layout.LayoutHints as LayoutHints
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.Reflect
import XMonad.Layout.LayoutScreens
import XMonad.Layout.DragPane
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Tabbed hiding (fontName)
import qualified XMonad.Layout.Named
import Data.IORef
import qualified XMonad.StackSet as W
import System.IO.Unsafe (unsafePerformIO)
import Data.List (isPrefixOf)
layouts = LayoutHints.layoutHints $ 
          avoidStruts $ 
          ((Mirror tiled `named` "Horiz")
           ||| (tiled `named` "Vert")
           ||| simpleTabbed
           ||| Full)
  where tiled = reflectHoriz $ Tall nmaster delta ratio
  	nmaster = 2
	ratio = 3/4
	delta = 3/100
        threecol = dragPaneSp Horizontal 0.2 0.5 2

named = flip XMonad.Layout.Named.named -- This way it can be used as an operator, and look normal

fontName :: String
fontName = "genera-jess14"

dmenu_cmd :: String
dmenu_cmd = "exe=`dmenu_path | dmenu -fn " 
	    ++ fontName 
	    ++ "` && eval \"exec $exe\""

shescape :: String -> String
shescape [] = []
shescape ('\'':a) = '\\':'\'':shescape a
shescape ('\\':a) = '\\':'\\':shescape a
shescape (a0:a) = a0:shescape a

xmobarWrite :: String -> X ()
xmobarWrite str = spawn $ "/home/thequux/local/bin/xmobar-write '" ++ shescape str ++ "'"

myLogHook :: X ()
myLogHook = do ewmhDesktopsLogHook
               dynamicLogString logPP >>= xmobarWrite
               return ()
    where logPP = xmobarPP{ppCurrent=xmobarColor "green" ""
                          ,ppVisible=xmobarColor "#c0ffc0" ""
                          ,ppHidden=xmobarColor "CornflowerBlue" ""
                          ,ppHiddenNoWindows=xmobarColor "gray40" ""
                          ,ppUrgent=xmobarColor "red" "" . xmobarStrip
                          ,ppTitle=xmobarColor "green" "" . shorten 140
                          }
          shorten :: Int -> String -> String
          shorten n xs | length xs < n = xs
                       | otherwise     = (take (n - length end) xs) ++ end
              where
                end = "..."

          xmobarColor :: String  -- ^ foreground color: a color name, or #rrggbb format
                      -> String  -- ^ background color
                      -> String  -- ^ output string
                      -> String
          xmobarColor fg bg = wrap t "</fc>"
              where t = concat ["<fc=", fg, if null bg then "" else "," ++ bg, ">"]

          -- ??? add an xmobarEscape function?
                        
          -- | Strip xmobar markup. Useful to remove ppHidden color from ppUrgent
          --   field. For example:
          --
          -- >     , ppHidden          = xmobarColor "gray20" "" . wrap "<" ">"
          -- >     , ppUrgent          = xmobarColor "dark orange" "" .  xmobarStrip
          xmobarStrip :: String -> String
          xmobarStrip = strip [] where
              strip keep x
                  | null x                 = keep
                  | "<fc="  `isPrefixOf` x = strip keep (drop 1 . dropWhile (/= '>') $ x)
                  | "</fc>" `isPrefixOf` x = strip keep (drop 5  x)
                  | '<' == head x          = strip (keep ++ "<") (tail x)
                  | otherwise              = let (good,x') = span (/= '<') x
                                             in strip (keep ++ good) x'
          -- | Wrap a string in delimiters, unless it is empty.
          wrap :: String  -- ^ left delimiter
               -> String  -- ^ right delimiter
               -> String  -- ^ output string
               -> String
          wrap _ _ "" = ""
          wrap l r m  = l ++ m ++ r

toggle :: IORef Bool -> X a -> X a -> X a
toggle ref ifTrue ifFalse =
    do val <- io $atomicModifyIORef ref (\x -> (not x,x))
       if val then ifTrue else ifFalse
      

screenMode :: IORef Bool
screenMode = unsafePerformIO $ newIORef True

mykeys (XConfig {modMask = modm}) = M.fromList $
   [ ((modm, xK_p), spawn dmenu_cmd) -- %! Launch dmenu
   , ((mod4Mask, xK_F2), spawn "xscreensaver-command -lock") -- %! Start screensaver
   , ((modm .|. controlMask, xK_space), toggle screenMode rescreen (layoutScreens 2 (Mirror $ Tall 0 0 (1/2))))
   --, ((modm .|. shiftMask .|. controlMask , xK_space), rescreen)
   , ((modm, xK_b), sendMessage ToggleStruts)
   , ((modm, xK_0), windows $ W.greedyView "IM")
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
main = xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig
    { borderWidth        = 1
    , terminal           = "urxvt"
    , modMask		 = mod4Mask
    , workspaces         = [ show a | a <- [1..9]] ++ ["IM"]
    -- , workspaces         = words "A B C" ++ [ "d" ++ show x | x <- [4..10] ]
    --                       t b l r
    -- , defaultGaps        = gaps -- [(16,3,0,0)]
    , keys		 = (\c -> mykeys c `M.union` keys defaultConfig c) 
    , layoutHook = layouts
    , logHook		 = myLogHook
    , focusedBorderColor = "red"
    --, manageHook         = manageDocks
    }
