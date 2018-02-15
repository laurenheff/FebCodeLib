DECLARE

fizz NUMBER(10);
buzz DECIMAL(10,2);

BEGIN

FOR fizz in 0..99 LOOP

buzz := (fizz + 1);
IF NOT REGEXP_LIKE((buzz / 3 ), '^([0-9])*[.period.]([0-9])*$') THEN
    IF NOT REGEXP_LIKE((buzz / 5 ), '^([0-9])*[.period.]([0-9])*$')THEN
        dbms_output.put_line('FIZZBUZZ');
    ELSE
        dbms_output.put_line('FIZZ');
    END IF;
ELSE
    IF NOT REGEXP_LIKE((buzz / 5 ), '^([0-9])*[.period.]([0-9])*$') THEN
        dbms_output.put_line('BUZZ');
    ELSE
        dbms_output.put_line(buzz);
    END IF;
END IF;

END LOOP;

END;​