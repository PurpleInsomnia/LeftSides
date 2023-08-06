package options;

#if desktop
import Discord.DiscordClient;
import sys.io.File;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

typedef CustomOptions = {
    var title:String;
    var rpcTitle:String;
    var options:Array<CustomOption>;
}

typedef CustomOption = {
    var name:String;
    var description:String;
    var varName:String;
    var type:String;
    var defaultVal:Dynamic;
    var selectable:String;
    var otherVariables:Dynamic;
}

class CustomOptionsSubState extends BaseOptionsMenu
{
    public function new(path:String)
    {
        var data:CustomOptions = Json.parse(File.getContent(Paths.preloadFunny("options/" + path + ".json")));

        title = data.title;
		rpcTitle = data.rpcTitle; //for Discord Rich Presence

        for (i in 0...data.options.length)
        {
            var so:Dynamic = data.options[i].selectable;
            var daType:String = "custom_" + data.options[i].type;
            if (daType == "custom_ignore_" + data.options[i].type)
            {
                daType = data.options[i].type;
            }

            var option:Option = new Option(
                data.options[i].name,
                data.options[i].description,
                data.options[i].varName,
                daType,
                data.options[i].defaultVal,
                so
            );
            if (data.options[i].otherVariables != null)
            {
                if (data.options[i].otherVariables.valueCaps != null)
                {
                    if (data.options[i].otherVariables.valueCaps.minValue != null)
                    {
                        option.minValue = data.options[i].otherVariables.valueCaps.minValue;
                    }
                    if (data.options[i].otherVariables.valueCaps.maxValue != null)
                    {
                        option.maxValue = data.options[i].otherVariables.valueCaps.maxValue;
                    }
                    if (data.options[i].otherVariables.valueCaps.changeValue != null)
                    {
                        option.changeValue = data.options[i].otherVariables.valueCaps.changeValue;
                    }
                    if (data.options[i].otherVariables.valueCaps.decimals != null)
                    {
                        option.decimals = data.options[i].otherVariables.valueCaps.decimals;
                    }
                    if (data.options[i].otherVariables.valueCaps.scrollSpeed != null)
                    {
                        option.scrollSpeed = data.options[i].otherVariables.valueCaps.scrollSpeed;
                    }
                }
                if (data.options[i].otherVariables.displayFormat != null)
                {
                    option.displayFormat = data.options[i].otherVariables.displayFormat;
                }
            }
            if (data.options[i].type == "useless")
            {
                option.type = "useless";
            }
            addOption(option);
        }

        super();
    }
}