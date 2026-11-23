import {createClient} from '@supabase/supabase-js';
export const supabase=createClient('https://msmdqdalkpxrboefkyjk.supabase.co','sb_publishable_cd_ytzCEdr9IMm33xmMYow_WvCqtNUR');
export type Plan={id:string;name:string;monthly_cents:number;first_month_cents:number;enrollment_cents:number;benefits:string[];active:boolean};
export type Enrollment={id:string;plan_id:string;status:string;created_at:string;user_id:string};
