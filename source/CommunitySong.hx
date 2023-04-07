package;

import haxe.Json;
import openfl.display.Bitmap;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import haxe.io.Bytes;
import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import community.CommunityMenu;

import flash.media.Sound;

using StringTools;

typedef CommunitySongFile = {
    var artist:String;
    var title:String;
    var color:Array<Int>;
    var downloadMessage:String;
}

typedef CommunityContender = {
    var songs:Array<String>;
    var link:String;
    var lastWinner:String;
    var status:String;
}

typedef CL = {
    var songList:Array<String>;
}

class CommunitySong
{
    public static var accessed:Bool = false;
    public static var songs:Array<String> = [];
    public static var files:Array<CommunitySongFile> = [];
    public static var contenderFile:CommunityContender = null;
    public static var songIcons:Array<String> = [];

    public static function loadSongs()
    {
        #if ALLOW_GITHUB
        var http = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/" + GithubShit.GF.communityLink);

        http.onBytes = function (data:Bytes)
		{
            accessed = true;
            File.saveBytes("community/list.json", data);
        }

        http.onError = function(msg)
        {
            trace(msg);
        }

        http.request();
        #end
    }

    public static function loadAssets()
    {
        #if ALLOW_GITHUB
        if (!accessed)
        {
            return;
        }

        new FlxTimer().start(2, function(tmr:FlxTimer)
		{
            var communityFile:CL = Json.parse(File.getContent("community/list.json"));
            var ftd:Array<String> = communityFile.songList;
            songs = ftd;

            for (i in 0...ftd.length)
            {
                if (!FileSystem.exists("community/songs/" + ftd[i] + ".wav"))
                {
                    var http2 = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/cs/" + ftd[i] + "/song.wav");

                    http2.onBytes = function(data:Bytes)
                    {
                        File.saveBytes("community/songs/" + ftd[i] + ".wav", data);
                    }

                    http2.onError = function(msg)
                    {
                        trace(msg);
                    }
                    http2.request();
                }

                if (!FileSystem.exists("community/images/" + ftd[i] + ".png"))
                {
                    var http3 = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/cs/" + ftd[i] + "/song.png");

                    http3.onBytes = function(data:Bytes)
                    {
                        File.saveBytes("community/images/" + ftd[i] + ".png", data);
                    }

                    http3.onError = function(msg)
                    {
                        trace(msg);
                    }
                    http3.request();
                }

                if (!FileSystem.exists("community/icons/" + ftd[i] + ".png"))
                {
                    var iconHttp = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/cs/" + ftd[i] + "/icon.png");

                    iconHttp.onBytes = function(data:Bytes)
                    {
                        File.saveBytes("community/icons/" + ftd[i] + ".png", data);
                        new FlxTimer().start(0.5, function(tmr:FlxTimer)
                        {
                            songIcons.push("community/icons/" + ftd[i] + ".png");
                        });
                    }

                    iconHttp.onError = function(msg)
                    {
                        trace(msg);
                    }

                    iconHttp.request();
                }
                else
                {
                    songIcons.push("community/icons/" + ftd[i] + ".png");
                }

                if (!FileSystem.exists("community/data/" + ftd[i] + ".json"))
                {
                    var http4 = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/cs/" + ftd[i] + "/song.json");

                    http4.onBytes = function(data:Bytes)
                    {
                        File.saveBytes("community/data/" + ftd[i] + ".json", data);

                        new FlxTimer().start(0.5, function(tmr:FlxTimer)
                        {
                            var newFile:CommunitySongFile = haxe.Json.parse(File.getContent("community/data/" + ftd[i] + ".json"));
                            files.push(newFile);
                        });
                    }

                    http4.onError = function(msg)
                    {
                        trace(msg);
                    }
                    http4.request();
                }
                else
                {
                    new FlxTimer().start(0.5, function(tmr:FlxTimer)
                    {
                        var newFile:CommunitySongFile = haxe.Json.parse(File.getContent("community/data/" + ftd[i] + ".json"));
                        files.push(newFile);
                    });
                }
            }

            var ccHttp = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/cs/contenderInfo.json");

            ccHttp.onBytes = function(data:Bytes)
            {
                File.saveBytes("community/contender.json", data);
                new FlxTimer().start(0.5, function(tmr:FlxTimer)
                {
                    contenderFile = haxe.Json.parse(File.getContent("community/contender.json"));
                });
            }

            ccHttp.onError = function(msg)
            {
                trace(msg);
            }

            ccHttp.request();
        });
        #end
    }

    public static function download(song:String, callback:Void->Void, parent:CommunityMenu)
    {
        #if ALLOW_GITHUB
        trace(song);
        var http = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/cs/" + song + "/song.zip");

        http.onBytes = function(data:Bytes)
        {
            if (!FileSystem.exists("community/downloads/" + song.toUpperCase() + ".zip"))
            {
                File.saveBytes("community/downloads/" + song.toUpperCase() + ".zip", data);

                new FlxTimer().start(0.5, function(tmr:FlxTimer)
                {
                    callback();
                });
            }
            else
            {
                lime.app.Application.current.window.alert("You already have a .zip file for this song installed.\nSilly goose. :)", "Download Error");
                parent.canPress = true;
            }
        }

        http.onError = function(msg)
        {
            trace(msg);
            lime.app.Application.current.window.alert("Uh Oh. Looks like the game had a bit of trouble getting the .zip file.\nCheck your internet connection and try again.", "Download Error");
            parent.canPress = true;
        }

        http.request();
        #end
    }
}