select courseID,
sum( case when score >= 60 then 1 
          else 0
		  end) as passnumber
sum( case wehn score < 60 then 1
          else 0
		  end) as failnumber
from score
group by courseID  