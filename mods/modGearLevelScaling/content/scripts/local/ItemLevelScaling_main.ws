// Hello, have a nice day


function getSettingToggle(setting : name) : bool
{
	var config: CInGameConfigWrapper;
    
    config = theGame.GetInGameConfigWrapper();
    
    return (bool)config.GetVarValue('ILS_Config', setting);
}


function getSettingOptions(setting : name) : int
{
	var config: CInGameConfigWrapper;
    
    config = theGame.GetInGameConfigWrapper();
    
    return (int)config.GetVarValue('ILS_Config', setting);
}


function scaleItemLevel(item : SItemUniqueId) : int
{
	var tag: CName;
	var inv: CInventoryComponent;
	var i, dif: int;
		
	inv = thePlayer.GetInventory();

	tag = 'None';

	LogChannel('ILS', "Scaling " + inv.GetItemName(item) + " BEGIN");

	if (getSettingToggle('ILS_Swords'))
	{
		if (inv.ItemHasTag(item, 'PlayerSilverWeapon'))
			tag = 'autogen_fixed_silver_dmg';
		else if (inv.ItemHasTag(item, 'PlayerSteelWeapon'))
			tag = 'autogen_fixed_steel_dmg';
	}
	
	if (getSettingToggle('ILS_Armor'))
	{
		if (inv.GetItemCategory(item) == 'armor')
			tag = 'autogen_fixed_armor_armor';
		else if (inv.GetItemCategory(item) == 'gloves')
			tag = 'autogen_fixed_gloves_armor';
		else if (inv.GetItemCategory(item) == 'boots' || inv.GetItemCategory(item) == 'pants')
			tag = 'autogen_fixed_pants_armor';
	}
	
	if (tag == 'None')
	{
		LogChannel('ILS', "Scaling item out of scope END");
		return 1;
	}
	
	dif = GetWitcherPlayer().GetLevel() - inv.GetItemLevel(item);
	
	if (dif > 0)
	{
		for (i = 0; i < dif; i += 1)
			inv.AddItemCraftedAbility(item, tag, true);
	}
	else if (dif < 0 && getSettingToggle('ILS_Downscale'))
	{
		for (i = 0; i < dif * -1; i += 1)
			inv.RemoveItemCraftedAbility(item, tag);
	}
	
	// old scaling
	/*while (inv.GetItemLevel(item) < GetWitcherPlayer().GetLevel())
		inv.AddItemCraftedAbility(item, tag, true);
	
	if (getSettingToggle('ILS_Downscale'))
	{
		while (inv.GetItemLevel(item) > GetWitcherPlayer().GetLevel())
			inv.RemoveItemCraftedAbility(item, tag);
	}*/
	
	LogChannel('ILS', "Scaling " + inv.GetItemName(item) + " END");
	return 0;
}


function itemLevelScaleHandling() : int
{
	var i, option: int;
	var items: array<SItemUniqueId>;
	var inv: CInventoryComponent;
	
	LogChannel('ILS', "Many items scale handling");
	
	if (!getSettingToggle('ILS_Enable'))
	{
		LogChannel('ILS', "ILS_Enable is off");
		return 1;
	}
	
	inv = thePlayer.GetInventory();
	
	option = getSettingOptions('ILS_Scope');
	if (option == 0)
		inv.GetAllItems(items);
	if (option == 1)
		items = GetWitcherPlayer().GetEquippedItems();
	else if (option == 2)
		inv.GetAllItems(items);
	else if (option == 3)
		items = inv.GetItemsByTag('scalable');
	
	for (i = 0 ; i < items.Size(); i += 1)
	{
		if (option == 2 && inv.GetItemQuality(items[i]) != 5)
			continue;
		
		scaleItemLevel(items[i]);
	}
	
	LogChannel('ILS', "Many items scale handling done");
	return 0;
}


function singleItemLevelScaleHandling(item: SItemUniqueId) : int
{
	var option : int;
	var inv: CInventoryComponent;

	LogChannel('ILS', "Single item scaling");
	
	if (!getSettingToggle('ILS_Enable'))
	{
		LogChannel('ILS', "ILS_Enable is off");
		return 1;
	}
	
	inv = thePlayer.GetInventory();
	
	option = getSettingOptions('ILS_Scope');
	if (option == 1 && !GetWitcherPlayer().IsItemEquipped(item))
	{
		LogChannel('ILS', "Item out of scope (0)");
		return 1;
	}
	else if (option == 2 && inv.GetItemQuality(item) != 5)
		return 1;
	else if (option == 3 && !inv.ItemHasTag(item, 'scalable'))
	{
		LogChannel('ILS', "Item out of scope (2)");
		return 1;
	}
	
	scaleItemLevel(item);
	
	LogChannel('ILS', "Single item scaling done");
	return 0;
}