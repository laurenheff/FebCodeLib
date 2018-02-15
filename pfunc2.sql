CREATE OR REPLACE FUNCTION query_CMS_customer
    (customer_last_name IN STRING, customer_first_name IN STRING)
    RETURN string
AS
    CMScustomer VARCHAR(4000);
    
    x integer; 
    y integer;
    z integer;
    i integer;
    j integer;
    k integer;
    
    cdata varchar(4000);
    
    cursor cstmrdata is
    SELECT cstmr_id,cstmr_title,cstmr_first_nm,cstmr_mid_init,cstmr_last_nm
    FROM CMS.CUSTOMERS
    WHERE cstmr_last_nm = customer_last_name and cstmr_first_nm = customer_first_name;
    
    cursor cstmraddress is
    SELECT CUSTOMER_ADDRESS.ADDR_ID,CUSTOMER_ADDRESS.STREET_LINE_1,CUSTOMER_ADDRESS.STREET_LINE_2,CUSTOMER_ADDRESS.CITY_NM,CUSTOMER_ADDRESS.ZIP_CD,CUSTOMER_ADDRESS.DEFAULT_IND,CUSTOMER_ADDRESS.CNTRY_CD,
    COUNTRY.DESCRIPTION,CUSTOMER_ADDRESS.STATE_CD
    FROM CMS.CUSTOMER_ADDRESS, CMS.COUNTRY
    WHERE CUSTOMER_ADDRESS.CNTRY_CD = COUNTRY.CNTRY_CD(+)
    AND CSTMR_ID in (select CSTMR_ID from CMS.CUSTOMERS where CSTMR_LAST_NM = customer_last_name
    and CSTMR_FIRST_NM = customer_first_name);
    
    cursor cstmrcontacts is
    SELECT cntct_id,home_phone_nbr,mobile_phone_nbr,email_addr,default_ind,preferred_method_cd
    FROM CMS.CUSTOMER_CONTACT
    where cstmr_id in (select cstmr_id from CMS.CUSTOMERS where cstmr_last_nm = customer_last_name
    and cstmr_first_nm = customer_first_name);
    
    cursor orders is
    SELECT ORDERS.ordr_id,ORDERS.ordr_dt,ORDERS.addr_id,ORDERS.ordr_total_cost,ORDERS.shipping_method_cd,ORDERS.delivery_dt,ORDERS.cancel_ind,ORDER_STATUS.description,
    ORDERS.complete_ind,ORDERS.return_ind,ORDERS.ordr_stat_cd,ORDERS.cntct_id
    FROM CMS.ORDERS, CMS.ORDER_STATUS 
    WHERE ORDERS.ORDR_STAT_CD = ORDER_STATUS.ORDR_STAT_CD(+)
    AND cstmr_id in (select cstmr_id from CMS.CUSTOMERS where cstmr_last_nm = customer_last_name
    and cstmr_first_nm = customer_first_name);
    
    cursor order_contents is
    SELECT ordr.ordr_contents_id,prdct.description,prdct.price_per_unit,ordr.prdct_cnt
    FROM CMS.ORDER_CONTENTS ORDR, CMS.PRODUCTS PRDCT 
    WHERE ORDR.PRDCT_ID = PRDCT.PRDCT_ID(+)
    AND ORDR_ID IN (SELECT ORDR_ID FROM CMS.ORDERS WHERE CSTMR_ID IN
    (SELECT CSTMR_ID FROM CMS.CUSTOMERS where cstmr_last_nm = customer_last_name
    and cstmr_first_nm = customer_first_name));
    
    cursor order_tracking is
    SELECT ordr_hist_id,stat_dt,ordr_stat_cd,notes
    FROM CMS.ORDER_TRACKING
    WHERE ORDR_ID IN (SELECT ORDR_ID FROM CMS.ORDERS WHERE CSTMR_ID IN
    (SELECT CSTMR_ID FROM CMS.CUSTOMERS where cstmr_last_nm = customer_last_name
    and cstmr_first_nm = customer_first_name))
    ORDER by stat_dt desc;
    
    TYPE cstmr_type IS TABLE OF cstmrdata%ROWTYPE;
    t_cstmr cstmr_type;
    
    TYPE addr_type IS TABLE OF cstmraddress%ROWTYPE;
    t_addr addr_type;
    
    TYPE cntct_type IS TABLE OF cstmrcontacts%ROWTYPE;
    t_cntct cntct_type;
    
    TYPE ordr_type IS TABLE OF orders%ROWTYPE;
    t_ordr ordr_type;
    
    TYPE contents_type IS TABLE OF order_contents%ROWTYPE;
    t_contents contents_type;

    TYPE tracking_type IS TABLE OF order_tracking%ROWTYPE;
    t_tracking tracking_type;
    
    cur_cstmr INTEGER;
    cur_addr INTEGER;
    cur_cntct INTEGER;
    cur_ordr INTEGER;
    cur_contents INTEGER;
    cur_tracking INTEGER; 

BEGIN
        
    OPEN cstmrdata;  
    LOOP
    FETCH cstmrdata BULK COLLECT INTO t_cstmr LIMIT 100;

        cur_cstmr := 0;

        FOR x IN 1..t_cstmr.COUNT LOOP
        
        cur_cstmr := cur_cstmr +1;

        cdata := 'Customer '||x||' Name:'||t_cstmr(x).cstmr_title||' '||t_cstmr(x).cstmr_first_nm||' '||t_cstmr(x).cstmr_mid_init||' '||t_cstmr(x).cstmr_last_nm||'
        ';
        
        OPEN cstmraddress;
        LOOP
        FETCH cstmraddress BULK COLLECT into t_addr LIMIT 100;

        cur_addr := 0;

            FOR y in 1..t_addr.COUNT LOOP
            
            cur_addr := cur_addr +1;

            cdata := cdata + 'Customer Address '||y||': '||t_addr(y).STREET_LINE_1||' '||t_addr(y).street_line_2||', '||t_addr(y).city_nm||', '||t_addr(y).state_cd||', '||t_addr(y).description||', '||t_addr(y).zip_cd||'
            ';
            
            END LOOP;
            EXIT WHEN cstmraddress%NOTFOUND;
        END LOOP;
        CLOSE cstmraddress; 
        
        OPEN cstmrcontacts;
        LOOP
        FETCH cstmrcontacts BULK COLLECT into t_cntct LIMIT 100;

        cur_cntct := 0;

            FOR z in 1..t_cntct.COUNT LOOP
            
            cur_cntct := cur_cntct +1;
            
            IF t_cntct(z).default_ind = 'Y' then
                IF t_cntct(z).home_phone_nbr is not null THEN
                    cdata := cdata + 'Primary Customer Home Phone: '||t_cntct(z).home_phone_nbr||'
                    ';
                END IF;
                IF t_cntct(z).mobile_phone_nbr is not null THEN
                    cdata := cdata + 'Primary Customer Mobile Phone: '||t_cntct(z).mobile_phone_nbr||'
                    ';
                END IF;
                IF t_cntct(z).email_addr is not null THEN
                    cdata := cdata + 'Primary Email Address: '||t_cntct(z).email_addr||'
                    ';
                END IF;
            ELSE
                IF t_cntct(z).home_phone_nbr is not null THEN
                    cdata := cdata + 'Additional Customer Home Phone: '||t_cntct(z).home_phone_nbr||'
                    ';
                END IF;
                IF t_cntct(z).mobile_phone_nbr is not null THEN
                    cdata := cdata + 'Additional Customer Mobile Phone: '||t_cntct(z).mobile_phone_nbr||'
                    ';
                END IF;
                IF t_cntct(z).email_addr is not null THEN
                    cdata := cdata + 'Additional Email Address: '||t_cntct(z).email_addr||'
                    ';
                END IF;
            END IF;

            IF t_cntct(z).preferred_method_cd is not null THEN
                IF t_cntct(z).preferred_method_cd = 'H' THEN
                     cdata := cdata + 'Preferred Contact Method: HOME PHONE  
                     ';
                ELSIF t_cntct(z).preferred_method_cd = 'M' THEN
                     cdata := cdata + 'Preferred Contact Method: MOBILE PHONE
                     ';
                ELSIF t_cntct(z).preferred_method_cd = 'E' THEN
                     cdata := cdata + 'Preferred Contact Method: EMAIL
                     ';
                END IF;
            END IF;
            
            END LOOP;
            EXIT WHEN cstmrcontacts%NOTFOUND;
        END LOOP;
        CLOSE cstmrcontacts;
        
        OPEN orders;
        LOOP
        FETCH orders BULK COLLECT into t_ordr LIMIT 100;

        cur_ordr := 0;

            FOR i in 1..t_ordr.COUNT LOOP
                
            cur_ordr := cur_ordr +1;
            IF t_ordr(i).shipping_method_cd = 'G' THEN
                 cdata := cdata + 'Customer Order No. '||t_ordr(i).ordr_id||' Placed on '||t_ordr(i).ordr_dt||' totaling $'||t_ordr(i).ordr_total_cost||' and shipped via Ground Transportation Has current status '||t_ordr(i).description||'
                 ';
            ELSIF t_ordr(i).shipping_method_cd = 'A' THEN
                 cdata := cdata + 'Customer Order No. '||t_ordr(i).ordr_id||' Placed on '||t_ordr(i).ordr_dt||' totaling $'||t_ordr(i).ordr_total_cost||' and shipped via Air Transportation Has current status '||t_ordr(i).description||'
                 ';
            ELSE 
                 cdata := cdata + 'Customer Order No. '||t_ordr(i).ordr_id||' Placed on '||t_ordr(i).ordr_dt||' totaling $'||t_ordr(i).ordr_total_cost||' Has current status '||t_ordr(i).description||'
                 ';
            END IF;

            IF (t_ordr(i).CANCEL_IND = 'Y' or t_ordr(i).RETURN_IND = 'Y') THEN
                cdata := cdata + '(Order Canceled or Returned)
                ';
            END IF;
            IF t_ordr(i).COMPLETE_IND = 'N' THEN
                cdata := cdata + '(Order status still pending)
                ';
            END IF;
            
                OPEN order_tracking;
                LOOP
                FETCH order_tracking BULK COLLECT into t_tracking LIMIT 100;

                cur_tracking := 0;

                    FOR j in 1..t_tracking.COUNT LOOP
                    
                    cur_tracking := cur_tracking +1;
                        
                    IF t_tracking(j).ordr_stat_cd != t_ordr(i).ordr_stat_cd THEN
                        IF t_tracking(j).ordr_stat_cd = 'D' THEN
                            cdata := cdata + 'Order delivery date: '||t_tracking(j).stat_dt||'
                            ';
                            IF t_tracking(j).notes is not null THEN
                                cdata := cdata + 'Delivery notes: '||t_tracking(j).notes||'
                                ';
                            END IF;
                        END IF;
                        IF t_tracking(j).ordr_stat_cd = 'S' THEN
                            cdata := cdata + 'Order shipment date: '||t_tracking(j).stat_dt||'
                            ';
                            IF t_tracking(j).notes is not null THEN
                                cdata := cdata + 'Shipment notes: '||t_tracking(j).notes||'
                                ';
                            END IF;
                        END IF;
                        IF t_tracking(j).ordr_stat_cd = 'P' THEN
                            cdata := cdata + 'Order processing date: '||t_tracking(j).stat_dt||'
                            ';
                            IF t_tracking(j).notes is not null THEN
                                cdata := cdata + 'Order placement notes: '||t_tracking(j).notes||'
                                ';
                            END IF;
                        END IF;
                    END IF;
                    
                    END LOOP;
                    EXIT WHEN order_tracking%NOTFOUND;
                END LOOP;
                CLOSE order_tracking;
                
                OPEN order_contents;
                LOOP
                FETCH order_contents BULK COLLECT into t_contents LIMIT 100;

                cur_contents :=0;

                    FOR k in 1..t_contents.COUNT LOOP
                        
                    cur_contents := cur_contents +1;
                        
                        cdata := cdata + 'Order includes '||t_contents(k).prdct_cnt||' units of '||t_contents(k).description||' ($'||t_contents(k).price_per_unit||' each).
                        ';
                    END LOOP;
                    EXIT WHEN order_contents%NOTFOUND;
                END LOOP;
                CLOSE order_contents;
                    
            END LOOP;
            EXIT WHEN orders%NOTFOUND;
        END LOOP;
        CLOSE orders;
    
        CMScustomer := CMScustomer + cdata;        
        
        END LOOP;    
    EXIT WHEN cstmrdata%NOTFOUND;
    END LOOP;
    CLOSE cstmrdata;

RETURN CMScustomer;

EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('query_CMS_customer has encountered an unexpected error - '||SQLERRM);   
END;
/​