function ret=normalize(x)
b=reshape(x.',1,[]);
ret=x./mean(x);
end