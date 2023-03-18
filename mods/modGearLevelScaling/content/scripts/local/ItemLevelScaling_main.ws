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
	
	while (inv.GetItemLevel(item) < GetWitcherPlayer().GetLevel())
		inv.AddItemCraftedAbility(item, tag, true);
	
	LogChannel('ILS', "Scaling " + inv.GetItemName(item) + " END");
	return 0;
}


function itemLevelScaleHandling() : int
{
	var i: int;
	var items: array<SItemUniqueId>;
	var inv: CInventoryComponent;
	
	LogChannel('ILS', "Many items scale handling");
	
	if (!getSettingToggle('ILS_Enable'))
	{
		LogChannel('ILS', "ILS_Enable is off");
		return 1;
	}
	
	inv = thePlayer.GetInventory();
	
	i = getSettingOptions('ILS_Scope');
	if (i == 0)
		items = GetWitcherPlayer().GetEquippedItems();
	else if (i == 1)
		inv.GetAllItems(items);
	else if (i == 2)
		items = inv.GetItemsByTag('scalable');
	
	for (i = 0 ; i < items.Size(); i += 1)
	{
		scaleItemLevel(items[i]);
	}
	
	LogChannel('ILS', "Many items scale handling done");
	return 0;
}


function singleItemLevelScaleHandling(item: SItemUniqueId) : int
{
	var i : int;
	var inv: CInventoryComponent;

	LogChannel('ILS', "Single item scaling");
	
	if (!getSettingToggle('ILS_Enable'))
	{
		LogChannel('ILS', "ILS_Enable is off");
		return 1;
	}
	
	inv = thePlayer.GetInventory();
	
	i = getSettingOptions('ILS_Scope');
	if (i == 0 && !GetWitcherPlayer().IsItemEquipped(item))
	{
		LogChannel('ILS', "Item out of scope (0)");
		return 1;
	}
	else if (i == 2 && !inv.ItemHasTag(item, 'scalable'))
	{
		LogChannel('ILS', "Item out of scope (2)");
		return 1;
	}
	
	scaleItemLevel(item);
	
	LogChannel('ILS', "Single item scaling done");
	return 0;
}