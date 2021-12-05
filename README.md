## Byzer Documentation

online docs: https://docs.byzer.org/ powered by [docsify](https://github.com/docsifyjs/docsify/)

## Document Structure
```
- _images: images for doc sites, not for doc content  
- _media: medias for doc sites
- byzer-notebook: content of byzer notebook docs
    - zh-cn
    - en-us
- kolo-lang: content of kolo-lang
    - zh-cn
    - en-us
- public: content of public blogs and shared slide
- index.html
- coverpage.md: the content of index.html
```

- If you add a new markdown file in `kolo-lang` or `byzer-notebook`, please make sure this file has been included in `_sidebar.md`
- If you want to cite pictures in the document, please create a `image` folder in the same level directory as the markdown file
- If you want to public a shared slide or blog, **please ensure that the material is desensitized**


## Contributing

Welcome to **file an ISSUE** or **submit a PR** when:
- If you find a bug
- If you want to improve
- If you want to post a blog or share a slide

**Before you submit a PR, please make sure you have previewed the content in local**

### How to preview docs in local
- Just fork byzer-doc to your repository
- Clone your repo to your local machine
- Install `docsify` by `npm -i docsify-cli -g`
- Run `cd /path/to/byzer-doc`
- Run `docsify serve ./`

## License
[Apache License Version 2.0](LICENSE)

## Contributors

This docment exists thanks to all the people who contribute.
<a href="https://github.com/byzer-org/byzer-doc/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=byzer-org/byzer-doc" />
</a>

[mlsql-docs](https://github.com/allwefantasy/mlsql-docs) is the predecessor of Byzer Docments, the contributors are listed below:

<a href="https://github.com/allwefantasy/mlsql-docs/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=allwefantasy/mlsql-docs" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

## Become the member of Byzer Docs User Group

If you want to become a member of byzer orgnization, you will be accepted after you contributed to this org.

If you want to join **Byzer Docs User Group**,  you can contribute the following things or more by:

- Post the blog or shared slides about any Byzer projects
- Write the documentation of Kolo-Lang or Byzer-Notebook
- Translate all the content to English

Then, just file an issue with the tile like `Join Byzer Docs User Group` 