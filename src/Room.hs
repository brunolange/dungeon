module Room(
    Room(..),
    fromTemplate,
    toString,
    takeItem,
    lookupEntity
) where

import qualified Entity
import qualified Item
import qualified EntityTemplate
import qualified ItemTemplate
import qualified RoomTemplate
import qualified RoomTemplateEntity
import qualified RoomTemplateItem
import Door(Door)
import qualified Door
import Lib(listToMap, join, applyTabs, popMap)
import Data.Map(Map)
import qualified Data.Map as Map

data Room = Room {
    name :: String,
    entities :: Map String Entity.Entity,
    items :: Map String Item.Item,
    doors :: Map String Door
} deriving Show

lookupEntity :: String -> Room -> Maybe Entity.Entity
lookupEntity name r = Map.lookup name (entities r)

toString :: Int -> Room -> String
toString t r = join
    "\n"
    (
        (applyTabs ["Room"] t)
        ++ (applyTabs ["Name: " ++ (name r)] (t+1))
        ++ (applyTabs ["Entities"] (t+1))
        ++ (map (Entity.toString (t+2)) (Map.elems (entities r)))
        ++ (applyTabs ["Items"] (t+1))
        ++ (map (Item.toString (t+2)) (Map.elems (items r)))
    )

fromTemplate :: Map String EntityTemplate.EntityTemplate -> Map String ItemTemplate.ItemTemplate -> Map String Int -> RoomTemplate.RoomTemplate -> Room
fromTemplate etm itm sb rt = Room {
    name=RoomTemplate.name rt,
    entities=listToMap
        (
            map
                (
                    \rte -> Entity.fromTemplate
                        (Map.lookup (RoomTemplateEntity.template rte) etm)
                        sb
                        rte
                )
                (RoomTemplate.entities rt)
        )
        Entity.name
        id,
    items=listToMap
        (
            map
                (
                    \rti -> Item.fromTemplate
                        (Map.lookup (RoomTemplateItem.template rti) itm)
                        rti
                )
                (RoomTemplate.items rt)
        )
        Item.name
        id,
    doors=(listToMap (RoomTemplate.doors rt) Door.name id)
}

updateItems :: Map String Item.Item -> Room -> Room
updateItems i r = Room {
    name=(name r),
    entities=(entities r),
    items=i,
    doors=(doors r)
}

takeItem :: String -> Room -> (Maybe Item.Item, Room)
takeItem s r =
    let
        (item, rest) = Lib.popMap s (items r)
    in
        (item, updateItems rest r)

