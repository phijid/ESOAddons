﻿function TamrielTradeCentre:InitSettingMenu()
	local panelData = {
		type = "panel",
		name = "Tamriel Trade Centre",
		author = "TamrielTradeCentre.com",
		version = "4.16.267.28139",
	}

	local optionsTable = {
		{
			type = "header", 
			name = GetString(TTC_SETTING_GENERALSETTINGS),
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_ENABLEAUTORECORDSEARCHRESULTS),
			tooltip = GetString(TTC_SETTING_ENABLEAUTORECORDSEARCHRESULTS_TOOLTIP),
			getFunc = function()
						  return self.Settings.EnableAutoRecordStoreEntries
					  end,
			setFunc = function(value)
						  self.Settings.EnableAutoRecordStoreEntries = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_ENABLEGUILDSALESDATACOLLECTION),
			getFunc = function()
						  return self.Settings.EnableSaleHistoryCollection
					  end,
			setFunc = function(value)
						  self.Settings.EnableSaleHistoryCollection = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_ENABLEMYGUILDLISTINGSUPLOAD),
			getFunc = function()
						  return self.Settings.EnableSelfEntriesUpload
				      end,
		    setFunc = function(value)
						  self.Settings.EnableSelfEntriesUpload = value
					  end,
		},
		{
			type = "slider",
			name = GetString(TTC_SETTING_MAXNUMBEROFAUTORECORDEDENTRIES),
			min = 0,
			max = 40000,
			step = 1000,
			getFunc = function()
						  return self.Settings.MaxAutoRecordStoreEntryCount
					  end,
			setFunc = function(value)
						  self.Settings.MaxAutoRecordStoreEntryCount = value
					  end,
			width = "full",
		},
		{
			type = "header",
			name = GetString(TTC_SETTING_SEARCHONLINE),
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_ENABLESEARCHONLINEBUTTON), 
			getFunc = function()
						  return self.Settings.EnableItemSearchOnlineBtn
					  end,
			setFunc = function(value)
						  self.Settings.EnableItemSearchOnlineBtn = value
					  end,
		},
		{
			type = "dropdown",
			name = GetString(TTC_SETTING_SEARCHONLINESORTBY), 
			choices = {
				GetString(TTC_SETTING_SEARCHONLINESORTBYLASTSEEN),
				GetString(TTC_SETTING_SEARCHONLINESORTBYPRICE)
			},
			choicesValues = {
				"LastSeen",
				"Price"
			},
			getFunc = function()
						  return self.Settings.SearchOnlineSort
					  end,
			setFunc = function(value)
						  self.Settings.SearchOnlineSort = value
					  end,
		},
		{
			type = "dropdown",
			name = GetString(TTC_SETTING_SEARCHONLINESORTORDER),
			choices = {
				GetString(TTC_SETTING_SEARCHONLINESORTASC),
				GetString(TTC_SETTING_SEARCHONLINESORTDESC)
			},
			choicesValues = {
				"asc",
				"desc"
			},
			getFunc = function()
						  return self.Settings.SearchOnlineOrder
					  end,
			setFunc = function(value)
						  self.Settings.SearchOnlineOrder = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_ENABLEPRICEHISTORYONLINEBUTTON), 
			getFunc = function()
						  return self.Settings.EnableItemPriceDetailOnlineBtn
					  end,
			setFunc = function(value)
						  self.Settings.EnableItemPriceDetailOnlineBtn = value
					  end,
		},
		{
			type = "header",
			name = GetString(TTC_SETTING_TOOLTIPSETTINGS),
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_ENABLEITEMPANELPRICINGINFO),
			tooltip = GetString(TTC_SETTING_ENABLEITEMPANELPRICINGINFO_TOOLTIP),
			getFunc = function()
						  return self.Settings.EnableItemToolTipPricing
					  end,
			setFunc = function(value)
						  self.Settings.EnableItemToolTipPricing = value 
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDESUGGESTEDPRICE),
			getFunc = function()
						  return self.Settings.EnableToolTipSuggested
					  end,
			setFunc = function(value)
						  self.Settings.EnableToolTipSuggested = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDESALEPRICE),
			getFunc = function()
						  return self.Settings.EnableToolTipSalePrice
					  end,
			setFunc = function(value)
						  self.Settings.EnableToolTipSalePrice = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDEAGGREGATE),
			getFunc = function()
						  return self.Settings.EnableToolTipAggregate
					  end,
			setFunc = function(value)
						  self.Settings.EnableToolTipAggregate = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDEENTRYCOUNT),
			getFunc = function()
						  return self.Settings.EnableToolTipStat
					  end,
			setFunc = function(value)
						  self.Settings.EnableToolTipStat = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDELASTUPDATETIME),
			getFunc = function()
						  return self.Settings.EnableToolTipLastUpdate
					  end,
			setFunc = function(value)
						  self.Settings.EnableToolTipLastUpdate = value
					  end,
		},
		{
			type = "header", 
			name = GetString(TTC_SETTING_PRICETOCHATSETTINGS),
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_ENABLEPRICETOCHATBUTTON),
			tooltip = GetString(TTC_SETTING_ENABLEPRICETOCHATBUTTON_TOOLTIP),
			getFunc = function()
						  return self.Settings.EnableItemPriceToChatBtn
					  end,
			setFunc = function(value)
						  self.Settings.EnableItemPriceToChatBtn = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDESUGGESTEDPRICE),
			getFunc = function()
						  return self.Settings.EnablePriceToChatSuggested
					  end,
			setFunc = function(value)
						  self.Settings.EnablePriceToChatSuggested = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDESALEPRICE),
			getFunc = function()
						  return self.Settings.EnablePriceToChatSalePrice
					  end,
			setFunc = function(value)
						  self.Settings.EnablePriceToChatSalePrice = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDEAGGREGATE),
			getFunc = function()
						  return self.Settings.EnablePriceToChatAggregate
					  end,
			setFunc = function(value)
						  self.Settings.EnablePriceToChatAggregate = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDEENTRYCOUNT),
			getFunc = function()
						  return self.Settings.EnablePriceToChatStat
					  end,
			setFunc = function(value)
						  self.Settings.EnablePriceToChatStat = value
					  end,
		},
		{
			type = "checkbox",
			name = GetString(TTC_SETTING_INCLUDELASTUPDATETIME),
			getFunc = function()
						  return self.Settings.EnablePriceToChatLastUpdate
					  end,
			setFunc = function(value)
						  self.Settings.EnablePriceToChatLastUpdate = value
					  end,
		},
		{
			type = "header", 
			name = GetString(TTC_CLEARDATA),
		},
		{
			type = "button",
			name = GetString(TTC_CLEARRECORDEDENTRIES),
			width = "full",
			func = function()
					   self:ClearRecordedEntries()
				   end,
		},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(GetString(TTC_SETTING_TTCOPTIONS), panelData)
	LAM:RegisterOptionControls(GetString(TTC_SETTING_TTCOPTIONS), optionsTable)
end