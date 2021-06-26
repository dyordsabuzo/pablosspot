from workers import thumbnail

filename='somefilenamefromtest'
thumbnail.create.delay('http://lorempixel.com/400/200/', filename)