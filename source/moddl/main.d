module moddl.main;

import std.file;
import std.stdio;
import std.algorithm, std.range, std.array;
import moddl.api, moddl.file, moddl.net, moddl.utils;

///各種設定
public {
  ///ファイルリストの名前
  auto fileListName = "currentFileList.json";
  ///API
  immutable apiRoot = "http://api.citringo.net/citserver/modpackage/v1/";
  ///鯖のID
  //immutable serverID = "Citserver11";
  ///ServerIDの設定ファイルの名称
  immutable serverIDName = "serverID.txt";
}

///API
CitserverAPI api;

///ファイルリストへの追加
auto addFileList(FileList currentList, FileList newList) {
  return newList.byValue.filter!(a => a.name !in currentList || a != currentList[a.name]).array;
}

///ファイルリストからの除去
auto deleteFileList(FileList currentList, FileList newList) {
  return currentList.byValue.filter!(a => a.name !in newList || a != newList[a.name]).array;
}

///ファイルの追加
void addFile(ref FileList currentList, FileList newList) {
  auto list = addFileList(currentList, newList);

  foreach (file; list) {
    auto downloader = DownloadFile(file.from);

    if (file.referer != "")
      downloader.referer = file.referer;

    downloader.targetDirectory = file.to;

    if (!exists(file.to))
      mkdirRecurse(file.to);

    //ファイルリストに対して変更を反映する
    if (file.name !in currentList)
      currentList[file.name] = file;

    currentList[file.name].fileName = downloader.fileName;

    writefln("Download %s(%s)", file.name, downloader.fileName);

    downloader.download;

    //unzipする必要があるならunzipする
    if (file.unzip) {
      writefln("Decompress %s", file.name);

      currentList[file.name].fileName = unzip(file.path);

      remove(file.path);
    }
  }
}

///ファイルの削除
void deleteFile(ref FileList currentList, FileList newList) {
  auto list = deleteFileList(currentList, newList);

  foreach (file; list) {
    if (file.path.exists) {
      if (file.path.isFile) {
        remove(file.path);
      }
      else {
        rmdirRecurse(file.path);
      }
    }

    //ファイルリストに対して変更を反映する
    currentList.remove(file.name);
  }
}
