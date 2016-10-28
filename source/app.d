import std.stdio;
import moddl.net;
import moddl.file;
import moddl.utils;
import moddl.api;
import std.algorithm, std.range, std.array;
import std.json;
import std.file;
import moddl.main;

void main(string[] args){
	auto api = CitserverAPI(apiRoot);
	string ver = api.latestVersion(serverID);

	writeln("ModInstaller");
	writefln("id:%s", serverID);
	writefln("version:%s", ver);

	auto newList = api.fileList(serverID, ver).toFileList;
	auto currentList = currentFileList();

	deleteFile(currentList, newList);
	addFile(currentList, newList);

	
	JSONValue root;
	root["files"] = JSONValue(currentList.toJSONValue);
	std.file.write(fileListName, (&root).toJSON);
}
