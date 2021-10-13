总结就是，先插入没有插过的，默认的点赞数啥的都是0，然后去更新今天的点赞数，分成两步了。
然后根据昨天的，比对今天的，来看增长数，如果今天新增了一门电子书，那么增长数就是自己的点赞数和阅读数
昨天的没有，默认就是0




#插入今天的,但是要求你之前没有插入过,根据id连接,看条件not exists
insert into ebook_snapshot(ebook_id, `date`, view_count, vote_count, view_increase, vote_increase)
select t1.id, curdate(), 0, 0, 0, 0
from ebook t1
where not exists(select 1
                 from ebook_snapshot t2
                 where t1.id = t2.ebook_id
                   and t2.`date` = curdate());
#更新今天的点赞数和阅读数,这个是从数据库里面查的,就是更新到这个中间表
update ebook_snapshot t1, ebook t2
set t1.view_count = t2.view_count, t1.vote_count = t2.vote_count
where t1.`date` = curdate()
  and t1.ebook_id = t2.id;
#获取昨天的数据
select t1.ebook_id,t1.view_count,t1.vote_count from ebook_snapshot t1
where t1.`date` = date_sub(curdate(),interval 1 day);
#更新今天的数据(BEFORE)
update ebook_snapshot t1,(select ebook_id,view_count,vote_count from ebook_snapshot
    where `date` = date_sub(curdate(),interval 1 day)) t2
set t1.view_increase = (t1.view_count - t2.view_count),
    t1.vote_increase = (t1.vote_count - t2.vote_count)
where t1.ebook_id = t2.ebook_id and t1.`date` = curdate();
#更新今天的数据(NOW)如果今天新增了一本电子书,那么它的增长的观看数和点赞数就是现在的观看数和点赞数,因为
#新增的没有今天和昨天的数据啊,没有,默认就是0
update ebook_snapshot t1 left join (select ebook_id,view_count,vote_count from ebook_snapshot
    where `date` = date_sub(curdate(),interval 1 day)) t2
on t1.ebook_id = t2.ebook_id
    set t1.view_increase = (t1.view_count - ifnull(t2.view_count,0)),
        t1.vote_increase = (t1.vote_count - ifnull(t2.vote_count,0))
where t1.`date` = curdate();

