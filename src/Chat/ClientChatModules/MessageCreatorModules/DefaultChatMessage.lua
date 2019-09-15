--	// FileName: DefaultChatMessage.lua
--	// Written by: TheGamer101
--	// Description: Create a message label for a standard chat message.

local clientChatModules = script.Parent.Parent
local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
local ChatConstants = require(clientChatModules:WaitForChild("ChatConstants"))
local util = require(script.Parent:WaitForChild("Util"))


function CreateMessageLabel(messageData, channelName)

	local fromSpeaker = messageData.FromSpeaker
	local message = messageData.Message

	local extraData = messageData.ExtraData or {}
	local useFont = extraData.Font or ChatSettings.DefaultFont
	local useTextSize = extraData.TextSize or ChatSettings.ChatWindowTextSize
	local usePrefix = extraData.Prefix or ChatSettings.DefaultPrefix
	local usePrefixColor = extraData.PrefixColor or ChatSettings.DefaultPrefixColor
	local useNameColor = extraData.NameColor or ChatSettings.DefaultNameColor
	local useChatColor = extraData.ChatColor or ChatSettings.DefaultChatColor
	local useChannelColor = extraData.ChannelColor or ChatSettings.DefaultMessageColor

	local formatPrefix = string.format("%s", usePrefix)
	local formatUseName = string.format("[%s]:", fromSpeaker)
	local speakerNameSize = util:GetStringTextBounds(formatUseName, useFont, useTextSize)
	local numNeededSpaces = util:GetNumberOfSpaces(formatPrefix, useFont, useTextSize) + util:GetNumberOfSpaces(formatUseName, useFont, useTextSize) + 1

	local BaseFrame, BaseMessage = util:CreateBaseMessage("", useFont, useTextSize, useChatColor)
	local NameButton = util:AddNameButtonToBaseMessage(BaseMessage, useNameColor, formatUseName, fromSpeaker)
	local PrefixLabel = util:AddPrefixLabelToBaseMessage(BaseMessage, usePrefixColor, formatPrefix)
	local ChannelButton = nil
	
	spawn(function()
		if PrefixLabel.Text == "[Creator] " then
			local h = 0
			while PrefixLabel and PrefixLabel.Parent do
				h = h + 1
				if h > 255 then
					h = 0
				end
				PrefixLabel.TextColor3 = Color3.fromHSV(h/255,1,1)
				game:GetService("RunService").Heartbeat:wait()
			end

		end
	end)

	if channelName ~= messageData.OriginalChannel then
		local formatChannelName = string.format("{%s}", messageData.OriginalChannel)
		ChannelButton = util:AddChannelButtonToBaseMessage(BaseMessage, useChannelColor, formatChannelName, messageData.OriginalChannel)
		PrefixLabel.Position = UDim2.new(0, ChannelButton.Size.X.Offset, 0, 0)
		NameButton.Position = UDim2.new(0, ChannelButton.Size.X.Offset + PrefixLabel.Size.X.Offset, 0, 0)
		numNeededSpaces = numNeededSpaces + util:GetNumberOfSpaces(formatChannelName, useFont, useTextSize)
	else
		PrefixLabel.Position = UDim2.new(0, 0, 0, 0)
		NameButton.Position = UDim2.new(0, PrefixLabel.Size.X.Offset, 0, 0)
	end

	local function UpdateTextFunction(messageObject)
		if messageData.IsFiltered then
			BaseMessage.Text = string.rep(" ", numNeededSpaces) .. messageObject.Message
		else
			BaseMessage.Text = string.rep(" ", numNeededSpaces) .. string.rep("_", messageObject.MessageLength)
		end
	end

	UpdateTextFunction(messageData)

	local function GetHeightFunction(xSize)
		return util:GetMessageHeight(BaseMessage, BaseFrame, xSize)
	end

	local FadeParmaters = {}
	FadeParmaters[PrefixLabel] = {
		TextTransparency = {FadedIn = 0, FadedOut = 1},
		TextStrokeTransparency = {FadedIn = 0.75, FadedOut = 1}
	}
	
	FadeParmaters[NameButton] = {
		TextTransparency = {FadedIn = 0, FadedOut = 1},
		TextStrokeTransparency = {FadedIn = 0.75, FadedOut = 1}
	}

	FadeParmaters[BaseMessage] = {
		TextTransparency = {FadedIn = 0, FadedOut = 1},
		TextStrokeTransparency = {FadedIn = 0.75, FadedOut = 1}
	}

	if ChannelButton then
		FadeParmaters[ChannelButton] = {
			TextTransparency = {FadedIn = 0, FadedOut = 1},
			TextStrokeTransparency = {FadedIn = 0.75, FadedOut = 1}
		}
	end

	local FadeInFunction, FadeOutFunction, UpdateAnimFunction = util:CreateFadeFunctions(FadeParmaters)

	return {
		[util.KEY_BASE_FRAME] = BaseFrame,
		[util.KEY_BASE_MESSAGE] = BaseMessage,
		[util.KEY_UPDATE_TEXT_FUNC] = UpdateTextFunction,
		[util.KEY_GET_HEIGHT] = GetHeightFunction,
		[util.KEY_FADE_IN] = FadeInFunction,
		[util.KEY_FADE_OUT] = FadeOutFunction,
		[util.KEY_UPDATE_ANIMATION] = UpdateAnimFunction
	}
end

return {
	[util.KEY_MESSAGE_TYPE] = ChatConstants.MessageTypeDefault,
	[util.KEY_CREATOR_FUNCTION] = CreateMessageLabel
}
