#!/usr/bin/env python

import os
import platform
from os import path
from dataclasses import dataclass

# -------- Config --------
cc = 'clang++'
cflags = ['-O1', '-fPIC']
ldflags = ['-L.']
packages = ['edit', 'some_utility'] # . is implictly included
exec_name = 'editor'

def pre_build():
    pass

def post_build():
    pass
# ------------------------

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
    kind : str # 'exec' | 'obj'
    translation_unit : str

    requires : list # List of Package's that are directly used in building
    uses : list     # Package artifacts that are needed, but not used directly in building

    def require(self, p):
        if self.kind == 'obj':
            raise Exception(f'Packages of type obj cannot require artifacts')
        self.requires.append(p)
        return self

    def use(self, p):
        self.uses.append(p)
        return self

    def artifact(self):
        bin_name = path.basename(self.path)
        if self.path == '.':
            bin_name = path.basename(path.abspath(self.path))

        if platform.system() == 'Windows':
            bin_name += '.obj' if self.kind == 'obj' else '.exe'
        else:
            bin_name += '.o' if self.kind == 'obj' else ''

        return bin_name

    def __init__(self, root: str):
        self.requires = []
        self.uses = []
        entries = os.listdir(root)
        entries = filter(lambda e: is_cpp_source(e) or is_header(e), entries)

        self.path = root
        self.files = list(entries)
        for e in self.files:
            if e.startswith('lib.') and is_cpp_source(e):
                self.kind = 'obj'
                self.translation_unit = e
            elif e.startswith('main.') and is_cpp_source(e):
                self.kind = 'exec'
                self.translation_unit = e

        if self.kind != 'obj' and self.kind != 'exec':
            raise Exception(f'Invalid package kind {self.kind}')

def lines(*args):
    buf = []
    for a in args:
        buf.append(str(a))
    return '\n'.join(buf)

NINJA_HEADER = lines(
    f'cxx = {cc}',
    f'cflags = {" ".join(cflags)}',
    f'ldflags = {" ".join(ldflags)}\n',
    'rule compile',
    '  command = $cxx -c $cflags -o $out $in',
    'rule build-exe',
    '  command = $cxx -o $out $in $ldflags\n',
)

def generate_ninja(pkg: Package):
    lines = []
    if pkg.kind == 'obj':
        line = f'build {path.join(pkg.path, pkg.artifact())}: compile {path.join(pkg.path, pkg.translation_unit)}'

        used_files = [path.join(used.path, used.artifact()) for used in pkg.uses]

        filepaths = [path.join(pkg.path, f) for f in pkg.files]
        deps = ' '.join(filepaths)
        line += ' | ' + deps

        lines.append(line)
    elif pkg.kind == 'exec':
        line = f'build {path.join(pkg.path, pkg.artifact())}: build-exe {path.join(pkg.path, pkg.translation_unit)}'

        req_files = [path.join(req.path, req.artifact()) for req in pkg.requires]
        used_files = [path.join(used.path, used.artifact()) for used in pkg.uses]

        line += ' ' + ' '.join(req_files)

        filepaths = [path.join(pkg.path, f) for f in pkg.files]
        deps = ' '.join(filepaths)
        line += ' | ' + deps + ' ' + ' '.join(used_files)

        lines.append(line)
    else:
        raise Exception(f'Invalid package kind {pkg.kind}')

    return '\n'.join(map(lambda l: l.strip(), lines))

def main():
    global packages
    packages.append('.')

    pdict = {}
    for p in packages:
        pdict[p] = Package(p)
    packages = pdict

    print(NINJA_HEADER)
    for _, pkg in packages.items():
        print(generate_ninja(pkg))


# Note about "Packages", C++ does **not** have real packages, this is a
# convention I made up for making unity builds easier, a "package" is a
# directory, it is treated as an executable if it has a `main.cpp` file and as
# a library if it has a `lib.cpp` file. This is the *only* compiled translation
# unit for that package. The point of this is to allow for basic modularization
# and platform specif abstraction without having to buy into some crazy and
# gargantuan build system, this is a limited approach on purpose. When
# compiling, the -I and -L flag automatically include the package directory.

if __name__ == '__main__': main()
