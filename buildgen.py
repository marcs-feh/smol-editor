#!/usr/bin/env python

import os
import platform
from os import path
from dataclasses import dataclass

# -------- Config --------
cc = 'clang++'
cflags = ('-O1', '-fPIC')
packages = ['.', 'edit']
# ------------------------

# Note about "Packages", C++ does **not** have real packages, this is a
# convention I made up for making unity builds easier, a "package" is a
# directory, it is treated as an executable if it has a `main.cpp` file and as
# a library if it has a `lib.cpp` file. This is the *only* compiled translation
# unit for that package. The point of this is to allow for basic modularization
# and platform specif abstraction without having to buy into some crazy and
# gargantuan build system, this is a limited approach on purpose. When
# compiling, the -I and -L flag automatically include the package directory.

def is_header(s: str) -> bool:
    s = s.strip().lower()
    for ext in ('.hh', '.h', '.hpp', '.h++'):
        if s.endswith(ext): return True
    return False

def is_cpp_source(s: str) -> bool:
    s = s.strip().lower()
    for ext in ('.cpp', '.cc', '.c++'):
        if s.endswith(ext): return True
    return False

@dataclass(init=False)
class Package:
    path : str
    files : list[str]
    kind : str # 'exec' or 'lib'
    translation_unit : str

    def __init__(self, root: str):
        entries = os.listdir(root)
        entries = filter(lambda e: is_cpp_source(e) or is_header(e), entries)
        self.path = root
        self.files = list(entries)
        for e in self.files:
            if e.startswith('lib.') and is_cpp_source(e):
                self.kind = 'lib'
                self.translation_unit = e
            elif e.startswith('main.') and is_cpp_source(e):
                self.kind = 'exec'
                self.translation_unit = e

        if self.kind != 'lib' and self.kind != 'exec':
            raise Exception(f'Invalid package kind {self.kind}')

def generate_ninja(pkg: Package):
    lines = []
    if pkg.kind == 'lib':
        line = ''
        bin_name = path.basename(pkg.path)
        if platform.system() == 'Windows':
            bin_name += '.obj'
        else:
            bin_name += '.o'

        line += f'build {path.join(pkg.path, bin_name)}: compile {path.join(pkg.path, pkg.translation_unit)}'
        filepaths = [path.join(pkg.path, f) for f in pkg.files]
        deps = ' '.join(filepaths)
        line += ' | ' + deps
        lines.append(line)

    return '\n'.join(lines)

packages = list(map(lambda p: Package(p), packages))
for pkg in packages:
    print(generate_ninja(pkg))
