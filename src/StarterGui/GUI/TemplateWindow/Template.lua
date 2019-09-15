--This is a comment :eyes:

local module = {}

function module.init(Modules)
	-- This function is called after all modules have been required
	-- Modules is a table of all of the modules, indexed by name only
	-- ex. module at GUI.ItemPreview.Frame.Preview is Modules.Preview
	-- TWO MODULES CANNOT HAVE THE SAME NAME!


	-- All sounds physically located at GUI.Menu.Menu.Sounds
	local Sounds = Modules.Menu.sounds

	script.Parent.Top.Close.MouseButton1Click:Connect(function()
		Sounds.Click:Play()

		-- Focus.close() takes care of everything. Gui objects
		-- should be an imagelabel with a shadow called "Depth"
		-- in order to properly tween in and out.
		Modules.Focus.close()

		-- Focus.change(GuiObject) displays the GuiObject while
		-- closing any object that is currently open. Handles
		-- xbox controls as well by automatically selecting a button.
	end)


	local BigNumber = -12300000000000000000000000000000000000
	-- Oh noes, a big number! How do we display this on a GUI?

	local MoneyLib = Modules.MoneyLib

	local NiceString
	-- For money:
	NiceString = MoneyLib.HandleMoney(BigNumber) --> -($12.3Ud)
	-- For everything else:
	NiceString = MoneyLib.DealWithPoints(BigNumber) --> 12.3Ud

	-- Other useful information:

	-- PlayerTycoon - Always set to the Tycoon that the Player OWNS
	local PlayerTycoon = game.Players.LocalPlayer.PlayerTycoon.Value

	-- ActiveTycoon - Set to the tycoon the player is currently EDITING
	-- (nil if not at a base they have permissions to edit)
	local ActiveTycoon = game.Players.LocalPlayer.ActiveTycoon.Value

	-- NearTycoon - Set to the tycoon the player is at, regardless of
	-- whether or not they have access to it. (nil if not at a tycoon)
	local NearTycoon = game.Players.LocalPlayer.NearTycoon.Value

	-- FOR SERVER -> USER INPUT, check GUI.Notifcations.Notify
	-- Use ReplicatedStorage.Hint, ReplicatedStorage.Currency or
	-- ReplicatedStorage.CurrencyPopup to send information to client.


	-- Important info:

	-- Use BoolValues titled "Xbox" "Mobile" AND/OR "PC" as children to make the
	-- parent only visible on those input modes. Using multiple tags is the same
	-- as an OR statement. If "Xbox" and "Mobile" are children, the parent will be
	-- visible on either input mode. This is automatic, you don't need to script anything.
	-- In fact, make sure you do not change the visibility of objects that have these tags
	-- as children because it will conflict. Use container objects if you wish to do this.

	-- DO NOT TOUCH ANYTHING IN SERVERSCRIPTSTORAGE.PLAYERDATAGUARDIAN
	-- LEAVE A COMMENT WITH DATE WHENEVER YOU CHANGE SOMETHING IN AN EXISTING SCRIPT
	-- LEAVE A COMMENT AT THE TOP OF ANY SCRIPT YOU CREATE EXPLAINING PURPOSE
	-- LEAVE INFORMATION IN GOOGLE DOC WHENEVER YOU MAKE A CHANGE.



end


return module