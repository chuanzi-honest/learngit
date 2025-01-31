Git is a version control system.
Git is a free software.
Create a new branch is quick.
查看分支：git branch
创建分支 git branch <name>
切换分支 git checkout <name> / git switch <name>
合并某分支到当前分支 git merge <name>
删除分支 git branch -d <name>
使用分支的Principle：main为主线，为final版本；操作尽量在 分支 dev上，可以有多个dev（多人协作，各自克隆一下远程库）。对用于git仓库的文件夹而言，后续可以直接在本地库（在我的macbook中，是/Users/zingli/learngit/）里添加各种do文件、数据文件，然后使用分支dev编辑，编辑后merge进main分支 然后一起上传到 github
  
如果手上分支完成一半，发现有其他bug，bug一般单独开个branch，可临时“储藏”刚刚的工作现场： $git stash 复原： $git stash pop
  假设dev上的也存在这个bug，无需重复，直接复制那个特定的提交 $git cherry-pick <commit>，这里的commit是在bug分支上做git commit的
