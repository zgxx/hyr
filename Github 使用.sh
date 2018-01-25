http://www.linuxidc.com/Linux/2014-03/97821.htm
  
root 登陆
apt-get install -y git

普通用户登陆
git config core.quotepath false     #取消中文被转义
umask 0002
mkdir /home/me/git
mkdir /home/me/git/fun
cd  /home/me/git/fun
git init

1 安装key
ssh-keygen -t rsa -b 4096 -C "dismark3@163.com"   #可以空密码
mousepad /home/me/.ssh/id_rsa.pub     #获得密匙

回到github，进入Account Settings，左边选择SSH Keys，Add SSH Key，title随便填，粘贴key。

测试ssh key是否成功，使用命令
ssh -T git@github.com
如果出现You’ve successfully authenticated, but GitHub does not provide shell access 。这就表示已成功连上github。

记住用户名密码
git config --global credential.helper store
git config --global user.name "zgxx"
git config --global user.email "dismark3@163.com"

使用命令关联远程fun
git remote add fun git@github.com:zgxx/fun.git

拉取远程库
git pull fun master --allow-unrelated-histories

比如你要添加一个文件xxx到本地仓库，使用命令
git add xxx
git add .       #自动判断添加哪些文件

然后把这个添加提交到本地的仓库，使用命令
git commit -m "说明这次的提交"

最后把本地仓库fun提交到远程的GitHub仓库，使用命令
git push -u fun master
git push -u --set-upstream hyr master      #为推送当前分支并建立与远程上游的跟踪

把更新的内容合并到本地分支，可以使用命令 
git merge fun/master
 
先有远程库的情况
#这个是获取其他人的库,$ git clone #版本库网址# #本地目录名#,该命令会在本地主机生成一个目录
git clone git@github.com:zgxx/auto_chat.git  auto_chat
git remote add auto_chat git@github.com:zgxx/auto_chat.git

git pull git@github.com:zgxx/auto_chat.git --allow-unrelated-histories
  
 常用操作：
git log --pretty=oneline     #显示单行的log
git status    #查看状态
git reset --hard HEAD^      #回退上个版本
git reset --hard 3628164    #版本回退
git reflog    #记录你的每一次命令
git checkout -- test.txt    #将工作区状态丢弃
git diff commit-id-1 commit-id-2    #显示两个版本的不同
git diff commit-id-1 commit-id-2 >> diff.txt   #显示两个版本的不同并导出到txt

GitHub的分支管理
创建
1 创建一个本地分支： git branch <新分支名字>
2 将本地分支同步到GitHub上面： git push <本地仓库名> <新分支名>
3 切换到新建立的分支： git checkout <新分支名>
4 为你的分支加入一个新的远程端： git remote add <远程端名字> <地址>
5 查看当前仓库有几个分支: git branch

删除
1 从本地删除一个分支： git branch -d <分支名称>
2 同步到GitHub上面删除这个分支： git push <本地仓库名> :<GitHub端分支>