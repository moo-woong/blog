---
title: "2022 10 17 Github Hugo"
date: 2022-10-16T08:15:52-07:00
---

# GitHub Blog와 Hugo로 블로그 만들기

## 개요
회사만 다니다보니 이 핑계, 저 핑계를 대며 개인업무 역량관리에 소홀한게 느껴졌습니다. 과거에도 공부할 때 하나하나 PPT자료를 만들며 체득했던 전공 공부, 정보들은 저한테는 좋은 경험이었습니다. 이에 대한 경험으로 블로그를 만들어 공부도 하고, 정리한 정보들을 공유하여 찾아오는 분들에게 득이되도록 하고 싶어 블로그를 만들어보게 되었습니다. 앞으로도 잘 부탁드리며 블로그 구축부터 정리해보겠습니다.

## 환경
- Blog: Github + Hugo
- Host machine: Ubuntu 20.04 LTS + VMWare workstation 16 
- Editor: VS Code on Windows

환경 선택에 대해서는 특별한 이유는 없습니다. Github blog에서는 Jekyll에서 Hugo로 넘어가는 포스팅도 많아서 Hugo를 선택했고 Ubuntu는 CentOS보다는 편해서, VMWare는 설치되어 있길래 사용했습니다. VSCode는 회사에서 개발환경이 Windows에서 Ubuntu로 remote 작업하기에 편해서 선택했습니다. 

## 설치
### Hugo 설치 및 설정

`Hugo`는 정적 사이트 생성기 입니다. 저와 여러분들이 만든 포스팅을 웹사이트의 컨텐츠로 예쁘게 만들어주는 도구죠. 다양한 테마를 설정할 수 있으며, 우리가 만든 포스트를 별도의 수고 없이 사이트로 만들어줍니다. 

Ubuntu에서 Hugo를 설치해 봅시다.

```
# sudo apt-get install hugo
```
{{< figure src="/images/hugo_install.png" title="Hugo 설치 결과" >}}

설치가 되었으니 블로그를 만들어보겠습니다.
```
# hugo new site blog
```
{{< figure src="/images/hugo_site.png" title="Hugo Site 생성" >}}

Blog를 생성했으니 예쁘게 만들어야겠죠? hugo는 jekyll, hexo와 같이 다양한 테마를 제공합니다. 아래 경로에 가시면 테마들을 구경하실 수 있습니다. 

https://themes.gohugo.io/

저는 많은 Star를 받은 테마 중 [`PaperMod`](https://github.com/adityatelange/hugo-PaperMod)라는 테마를 사용했습니다.

`git submodule`을 이용하여 papermod 테마를 clone하고 submodule로 관리해 보겠습니다. submodule 실행은 hugo로 blog를 개설한 `~/blog`에서 진행합니다. 

```
#cd ~/blog
#git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
```
{{< figure src="/images/papermod.png" title="PaperMod theme설치" >}}

PaperMod 테마를 theme 하위 경로에 clone 했습니다. 이제 이 테마를 hugo에서 사용하도록 변경해야 합니다. `blog`의 최상단에 `config.toml`파일을 통해서 hugo 테마를 변경할 수 있으나, PaperMod에서는 yaml 포맷의 [샘플](https://github.com/adityatelange/hugo-PaperMod/wiki/Installation#sample-configyml)을 제공합니다. 해당 내용을 복사해서 blog 경로 하위에 config.yaml을 만들어줍시다.

{{< figure src="/images/configyaml.png" title="샘플 config.yaml" >}}

`theme` 필드가 PaperMod로 되어 있어 hugo는 PaperMod 테마를 적용합니다. 이제 첫번째 post를 만들어보겠습니다. 

```
#hugo new posts/First_commit.md
```
{{< figure src="/images/first_commit.png" title="post 생성 로그" >}}

로그에 보이는대로, contents하위 경로에 포스트가 생성됩니다. 저는 posts/First_commit.md로 생성했으므로 blog/contents/posts/First_commit.md에 파일이 생성되었습니다. 

제가 앞서 Hugo는 정적 사이트 생성기라고 말했습니다. 이제 우리는 post를 만들었으니 해당 post를 가지고 사이트에 이쁘게 나오도록 해보겠습니다. `Hugo` 명령어를 통해서 사이트를 생성해보겠습니다.

```
hugh@ubuntu:~/blog$ hugo

                   | EN  
-------------------+-----
  Pages            | 15  
  Paginator pages  |  0  
  Non-page files   |  0  
  Static files     |  0  
  Processed images |  0  
  Aliases          |  2  
  Sitemaps         |  1  
  Cleaned          |  0  

Total in 62 ms
hugh@ubuntu:~/blog$
```
이렇게 빌드를 하게되면 Hugo가 theme를 기반으로 post가 게시된 사이트를 생성하게 됩니다. 빌드 결과는 hugo blog의 최상위 경로의 `public` 디렉토리에 생성됩니다.

{{< figure src="/images/public.png" title="public directory" >}}

여태까지 우리는 다음 작업을 수행했습니다.
1. Hugo 설치
2. Blog 생성
3. Theme 설치
4. Post 생성
5. 사이트 빌드

여기까지 수행하면 로컬에 사이트를 만들었습니다. `Hugo`웹엔진을 포함하고 있어 `server`명령어를 통해서 localhost로 웹페이지를 실행시킬 수 있습니다. 아래 명령어를 통해서 웹페이지가 정상적으로 보이는지 확인해보겠습니다.

```
# hugo server -D
```
{{< figure src="/images/hugo_server.png" title="Hugo server 실행화면" >}}

실행화면에 보이는것 처럼 기본 포트는 1313입니다. 웹클라이언트를 통해서 접속해보겠습니다.

{{< figure src="/images/web_page.png" title="웹클라이언트에서 로컬서버 접속 화면" >}}

저는 지금 새로운 포스팅을 하고 있으므로 두 개의 포스트가 보이네요 :) 여기까지 수행하면 로컬에서 블로그 포스팅이 가능하겠네요! 하지만 혼자 저장할거라면 Notion이나 다른 서비스를 사용해도 되겠죠. 우리의 목표는 정보를 기록하고 공유해야하므로 외부에 노출시켜야 합니다. 이제 Github blog를 통해서 포스트를 원격에 저장하고 이를 public 도메인으로 접속할 수 있도록 Github blog를 설정해 보겠습니다.

### Github Repository 준비
Hugo로 생성한 포스팅을 Github blog를 통해 관리하려면 두 개의 repository를 생성해야 합니다.

- **blog** </br>

    blog repository는 Hugo의 root path입니다. `Hugo new site blog`로 생성한 파일들을 여기에 저장하고 관리할 겁니다. `Hugo new` 로 생성한 포스트가 contents에 저장되며, `Hugo`를 이용해 생성한 사이트 폴더, 테마 폴더를 submodule로 갖고있습니다.

- **{github_id}.github.io** </br>

    Hugo를 통해 생성한 사이트가 저장되는 repository 입니다. 외부에서 해당 경로로 접근하며, 우리는 Hugo를 통해서 사이트를 생성했으므로 테마가 적용된 예쁜 사이트를 볼 수 있습니다.

{{< figure src="/images/github_repository.png" title="Github repository" >}}

이제 우리는 두 개의 관리용 Github repository를 생성했고, 로컬에는 Hugo를 설치하고 첫 번째 포스팅을 작성했습니다. 이제 로컬에 있는 Hugo 설정들과 포스팅을 Github repository와 연동해 보겠습니다.

#### blog와 hugo root path 연결
`hugo new site`를 통해 생성한 blog 경로로 이동하여 여기에 blog repository를 연결하겠습니다.
```
#git init
#git remote add origin {repository_url}
```
`repository_url`에 여러분들의 blog repository 경로를 입력하시면 됩니다. 이렇게하면 해당 경로를 우리가 앞서 생성한 blog repository에서 관리할 수 있습니다. `repository_url`의 경로는 여러분의 Github blog repository에서 `Code`를 누르면 확인할 수 있습니다.

{{< figure src="/images/repository_url.png" title="Github에서 repository url 확인방법" >}}

{{< figure src="/images/git_remote_command.png" title="Git origin 추가" >}}

다음으로는 실제 사이트가 저장되고 실행되는 repository를 Hugo root path에서 public 폴더와 submodule로 연동시켜 보겠습니다.

```
#git submodule add -b master {github.io_url} public
```
`{github.io_url}`에는 blog repository에서 확인했던 대로 여러분의 github.io 주소를 입력해주시면 됩니다.
{{< figure src="/images/githubio.png" title="github.io submodule 추가" >}}

자 여기까지 하면 우리는 Github과의 연동도 끝났습니다! 이제 새로운 포스팅을 하나 생성하고 Gitpub에 push 해서 public 도메인으로 우리 블로그가 제대로 보여지는지 확인해보겠습니다.

1. 새로운 포스팅 생성
```
#hugo new posts/second.md
```
2. 포스팅 수정
```
#vim contents/posts/second.md
```
{{< figure src="/images/second.png" title="새로운 포스팅 수정" >}}
3. Hugo 빌드
```
hugh@ubuntu:~/blog$ hugo

                   | EN  
-------------------+-----
  Pages            | 13  
  Paginator pages  |  0  
  Non-page files   | 13  
  Static files     |  0  
  Processed images |  0  
  Aliases          |  2  
  Sitemaps         |  1  
  Cleaned          |  0  

Total in 89 ms
hugh@ubuntu:~/blog$ 
```
4. 