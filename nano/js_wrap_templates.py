#!/usr/bin/env python3

import argparse
import os

def main():  # type: () -> None
    parser = argparse.ArgumentParser("NanoUI .tmpl -> .tmpl.js wrapper.")
    parser.add_argument("directory", default="templates", nargs="?")

    parsed = parser.parse_args()
    directory = parsed.directory  # type: str

    for filename in os.listdir(directory):
        if not filename.endswith(".tmpl"):
            continue

        print(filename)

        fullname = os.path.join(directory, filename)

        with open(fullname, "r") as f:
            contents = f.read()

        out = [f"NanoTemplate.preloadTemplate(\"{filename}\", \""]

        for c in contents:
            if c == "\t":
                out.append("\\t")
            elif c == "\n":
                out.append("\\n")
            elif c == "\r":
                out.append("\\r")
            elif c == "'":
                out.append("\\'")
            elif c == "\"":
                out.append("\\\"")
            elif c == "\\":
                out.append("\\\\")
            else:
                out.append(c)

        out.append("\");")

        concatenated = "".join(out)

        with open(fullname + ".js", "w") as f:
            f.write(concatenated)


if __name__ == "__main__":
    main()