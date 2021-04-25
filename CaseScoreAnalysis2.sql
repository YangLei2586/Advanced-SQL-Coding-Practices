select courseID, courseName,
sum(case when score between 85 and 100 then 1
         else 0
	end) as A
sum(case when score >=70 and score<85  then 1
         else 0
	end) as B
sum(case when score >=60 and score <70 then 1
         else 0
	end) as C
sum(case when score < 60 then 1
         else 0
	end) as D
from score as a right join course as b
on a.courseID = b.courseID
group by a.courseID, b.courseName