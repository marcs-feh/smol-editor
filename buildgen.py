#!/usr/bin/env python

from os import path, listdir
from dataclasses import dataclass
from platform import system as system_name

# -------- Config --------
cc = 'clang++'
cflags = ['-O1', '-fPIC', '-pipe', '-fno-strict-aliasing']
ldflags = ['-L.']
packages = ['core', 'edit']
exec_name = 'editor'

output = 'build.ninja'
# ------- Build ---------
def main():
    global packages, cflags, ldflags, exec_name, output
    packages.append('.')
    packages = { p: Package(p) for p in packages }

    cflags += [f'-I{p.path}' for p in packages.values()]
    ldflags += [f'-L{p.path}' for p in packages.values()]

    (packages['.']
        .require(packages['core'])
        .require(packages['edit'])
        .use_file('buildgen.py'))

    b_written = 0
    with open('build.ninja', 'w') as f:
        b_written += f.write(ninja_header(cc, cflags, ldflags) + '\n')
        build_steps = ''
        for _, pkg in packages.items():
            build_steps += generate_ninja(pkg) + '\n'
        b_written += f.write(build_steps)

    print(f'Packages: {len(packages)}')
    print(f'Output File: {output} [Wrote {round(b_written / 1024, 2)}KiB]')
# ---------------------

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

    requires : list # List of Packages that are directly used in building
    uses : list     # Package Packages that are needed, but not used directly in building

    file_requires : list # List of filed that are directly used in building
    file_uses : list     # Package files that are needed, but not used directly in building


    def require(self, p):
        if self.kind == 'obj':
            raise Exception(f'Packages of type obj cannot require packages/artifacts')
        self.requires.append(p)
        return self

    def use(self, p):
        self.uses.append(p)
        return self

    def use_file(self, path):
        self.file_uses.append(path)
        return self

    def require_file(self, path):
        if self.kind == 'obj':
            raise Exception(f'Packages of type obj cannot require packages/artifacts')
        self.file_requires.append(path)

    def artifact(self):
        bin_name = path.basename(self.path)
        if self.path == '.':
            bin_name = path.basename(path.abspath(self.path))

        if system_name() == 'Windows':
            bin_name += '.obj' if self.kind == 'obj' else '.exe'
        else:
            bin_name += '.o' if self.kind == 'obj' else ''

        return bin_name

    def __init__(self, root: str):
        entries = listdir(root)
        entries = filter(lambda e: is_cpp_source(e) or is_header(e), entries)

        self.requires = []
        self.uses = []
        self.file_requires = []
        self.file_uses = []

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

def ninja_header(cc, cflags, ldflags):
    return lines(
        f'cxx = {cc}',
        f'cflags = {" ".join(cflags)}',
        f'ldflags = {" ".join(ldflags)}\n',
        'rule compile',
        '  command = $cxx -c $cflags -o $out $in',
        'rule build-exe',
        '  command = $cxx -o $out $in $ldflags\n',
    )

def generate_ninja(pkg: Package):
    action = 'compile' if pkg.kind == 'obj' else 'build-exe'

    required_files = [path.join(req.path, req.artifact()) for req in pkg.requires] + pkg.file_requires
    used_files = [path.join(used.path, used.artifact()) for used in pkg.uses] + pkg.file_uses

    filepaths = [path.join(pkg.path, f) for f in pkg.files]

    out = [f'build {path.join(pkg.path, pkg.artifact())}: {action} {path.join(pkg.path, pkg.translation_unit)}']

    if pkg.kind == 'exec':
        out.append(" ".join(required_files))

    out.append('| ' + ' '.join(used_files + filepaths))

    return ' '.join(out).strip()


if __name__ == '__main__': main()

'''
This is a simple mini build system to help you generate a build.ninja file from
a set of directories called "packages".

Note that C++ does **not** have real packages, this is a convention I made up
for making unity builds easier, a "package" is a directory, it is treated as an
executable if it has a `main.cpp` file and as a library[1] if it has a `lib.cpp`
file. This is the *only* compiled translation unit for that package. The point
of this is to allow for basic modularization and platform specific abstraction
without having to buy into some crazy and gargantuan build system, this is a
limited approach on purpose.

Because there's only one translation unit per package, archiving objects is not
required, so a library is just one object file.

TODO: Dynamic libraries

When compiling, the -I and -L flag automatically include the package directory.
'''
