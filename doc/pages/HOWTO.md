@page howto How to use GitHub Pages for documentation

Blah blah

@dot

digraph dataflow {
  rankdir=LR
  node[fontname=Helvetica,fontsize=10,width=1,height=0.4]
  node[shape=box]
  pages[label="doc/pages/*.md"]
  images[label="doc/images/*"]
  litprog[label="doc/litprog/*.nw"]
  woven[label="doc/woven/*.md"]
  src[label="src/*.nim"]
  html[label="doc/html/*"]
  tmp[label="tmp.nw"]
  node[shape=oval]
  cat
  weave
  tangle
  doxygen

  litprog -> weave -> woven -> doxygen -> html
  pages -> doxygen
  images -> doxygen
  litprog -> cat -> tmp -> tangle -> src
}
@enddot

Thanks to 
[https://github.com/smartell/APIDemo](https://github.com/smartell/APIDemo)
for showing the way around GitHub

## 1. Initial Setup

blah

```
git clone https://github.com/colinc904/wangle.git
mkdir -p doc/html
echo 'doc/html/' >>.gitignore
cd doc/html
git clone https://github.com/colinc904/wangle.git
git checkout origin/gh-pages -b gh-pages
git branch -d master

```

## 2. Committing Changes

blah

```
gc
git push origin master
cd doc/html
ga .
gc
git push origin gh-pages
```


## 3. Cloning the Repo

blah

```
git clone https://github.com/colinc904/wangle.git   # gcl
cd doc/html
git clone https://github.com/colinc904/wangle.git  # gcl
git checkout gh-pages  # gcb
```

