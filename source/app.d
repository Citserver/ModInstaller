import std.stdio;
import moddl.net;
import moddl.file;
import moddl.utils;
import moddl.api;
import std.algorithm, std.range, std.array;
import std.json;
import std.file;
import moddl.main;

void main(string[] args) {
  auto api = CitserverAPI(apiRoot);
  string serverID = "";

  if (exists(serverIDName)) {
    serverID = serverIDName.readText;
  }
  while (serverID == "") {
    writeln("Type Pack ID >> ");
    import std.string : strip;
    serverID = readln.strip;
  }
  if (!exists(serverIDName)) {
    std.file.write(serverIDName, serverID);
  }

  string ver;
  try {
    ver = api.latestVersion(serverID);
  }
  catch (Exception e) {
    writeln("ERROR!!! " ~ e.msg);
    serverIDName.remove;
    return;
  }

  writeln("ModInstaller");
  writefln("id:%s", serverID);
  writefln("version:%s", ver);

  auto newList = api.fileList(serverID, ver).toFileList;
  auto currentList = currentFileList();

  deleteFile(currentList, newList);
  addFile(currentList, newList);

  JSONValue root;
  root["files"] = JSONValue(currentList.toJSONValue);
  std.file.write(fileListName, root.toJSON);
}
