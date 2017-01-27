module moddl.net;

import std.net.curl;
import std.conv;

public struct DownloadFile {
  this(string _url) {
    http = HTTP(_url);
    url_ = _url;
    //適当にUAを偽装しておく
    string ua = "Mozilla/5.0 (X11; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0";
    http.setUserAgent(ua);
  }

  private HTTP http;

  private string url_;
  @property {
    string url() {
      return url_;
    }

    void url(string a) {
      url_ = a;
      http.url = a;
    }
  }

  private string referer_;
  @property {
    string referer() {
      return referer_;
    }

    void referer(string a) {
      referer_ = a;
      http.addRequestHeader("Referer", a);
    }
  }

  private string fileName_ = "";
  @property {
    string fileName() {
      if (fileName_ == "") {
        fileName_ = getFileName(http, url);
      }
      return fileName_;
    }
  }

  public string targetDirectory;

  public void download() {
    import std.path;
    import std.stdio, std.conv;

    http.onProgress((dlTotal, dlNow, ulTotal, ulNow) {
      import std.stdio;

      writef("%d:%d(%0.2f%%)...\r", dlNow, dlTotal, dlNow.to!real / dlTotal.to!real * 100);
      stdout.flush();
      return 0;
    });
    std.net.curl.download(url, buildPath(targetDirectory, fileName), http);
    write("\n");
  }
}

private string[string] header(HTTP http) {
  string[string] data;

  auto back = http.method;

  http.method = HTTP.Method.head;
  http.onReceiveHeader((in char[] key, in char[] value) { data[key] = value.to!string; });
  http.perform();

  http.method = back;

  return data;
}

private string getFileName(HTTP http, string url) {
  auto header = http.header;

  import std.regex;

  if ("content-disposition" in header) {
    import std.algorithm.searching;

    auto content = header["content-disposition"];
    if (canFind(content, "filename=")) {
      //basic
      auto c = content.matchFirst(regex(`filename="?(?P<value>[^"]+)"?`));
      return c["value"];
    }
    else if (canFind(content, "filename*=")) {
      //ext
      auto c = content.matchFirst(regex(`filename\*=([^']*)'([^']*)'(?P<value>[^']+)`));
      return c["value"];
    }
    else {
      assert(0);
    }
  }
  else {
    return url.matchFirst(regex(`/(?P<value>[^\?/]+?)(\?.*)?$`))["value"];
  }
}
