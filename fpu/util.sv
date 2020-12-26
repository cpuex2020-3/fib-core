function shortreal abs(input shortreal x);
   if (x >= 0) return (x);
   else        return (-x);
endfunction

function shortreal max(input shortreal x, input shortreal y);
   if (x >= y) return (x);
   else        return (y);
endfunction
