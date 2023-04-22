#!/usr/bin/perl
# Contact Sandeep Chakravorty
# schakravorty@invensense.com

use strict;
use Cwd;

use threads;
use threads::shared;
use File::Copy;

my $root = $ENV{'PROJECT_PATH'};
my $build_dir = "";

my $cwd = $ENV{'PWD'};

my $ncv_build = "irun +define+NCV ";
my $ncv_build64 = "irun -64bit +define+NCV ";
my $vcs_build = "vcs -sverilog -debug_pp +define+VCS ";
my $vcs_build64 = "vcs -sverilog -debug_pp -full64 -cm assert +define+VCS ";
my $questa_build_lib = "vlib work";
my $questa_build32 = "vlog -32 +define+QUESTA ";
my $questa_build64 = "vlog -64 +define+QUESTA ";
my $questa_build_opt = "";
my $questa_vopt_args = "";
my $questa_elab_opts = "";
my $questabuild_cmd = "";
my $questa_upf = "";

my $cpf = "";
my $cpf_passed = 0;
my $upf = "";
my $upf_passed = 0;

my $qwave_arg = "+signal+cells";

my $user = $ENV{'USER'};
my $project_name = $ENV{'PROJECT_NAME'};
my $project_version = $ENV{'PROJECT_VERSION'};
my $verifroot = "$root/work/$user/verif";

my $block = "fifo";
my $throttle = 3;
my $max_run_time = 1440;
my @mail_receiver = ();
my $mail_receipients = ();
my %test_name_used = ();

my $min_status = 0;
my $gui = 0;

my $status_freq = 0;
my $job_group = "";
my $job_q = "normal";
my $job_priority = "normal";
my $resource = "";

my $wait = 1;
my $script = "";

my $postscript = "";
my $post_script = "";
my $builddebug = 0;

my $runargs = "";
my $var1 = "-var1=0 ";
my $var2 = "-var2=0 ";
my $var3 = "-var3=0 ";
my $var4 = "-var4=0 ";
my $var5 = "-var5=0 ";
my $nomail = 1;
my $status_mail = 0;

my $regr_dir = "";
my $setname = "";

my $seen_log = 0;
my $rerun_failed = 0;
my $rerun_failed_string = "";
my $num_dirs = 0;

my @regr_array = ();

my $grid = 0;

my $regr = "";

my $sims_dash_args = "";

my $block_name = "";
my $block_name_passed = 0;

my $separate_run_path = 0;

my $script_name = "";
my $force = 0;
my $ignoresimerror = "";

my $tbroot = $ENV{'TB_ROOT'};
my $rtlroot = $ENV{'RTL_ROOT'};

my $build_path = "$tbroot";

my $run_q = "sj-regrrbb";
my $build_q = "sj-regrrbb";
my $job_set = "";

my $build64 = 0;
my $run64 = 0;

my $build = 0;
my $whichbuild = "questa";

my $run = 1;
my $whichrun = "questa";

my $norun = 0;
my $nobuild = 0;

my $noassert = 0;

my $flist = "";
my $defines = " +define+norammessages +define+notestmodemessages +define+no_rw_collision_msg ";
my $file = "";
my $file_passed = 0;

my $buildcmd = "";
my $runcmd = "";

my $uvmhome = $ENV{'UVMHOME'};
my $IESHOME = $ENV{'IESHOME'};

my $run_name = "";

my $model_name = "work";

my $num_tests="-num_tests=1";

my $simulator_dash_args = "";
my $simulator_run_args = "";

my $dumpopts = "";
my $dumpfile = "master_test";

my $tl_run = 0;
my $coverage = 0;
my $merge_coverage = 0;
my $merge_cov_tool = "imc";
my $ena_old_cov_merge = 0;
my $coverage_args = "";
my $complete_coverage_args = "";

my $nowait = 0;
my $wait = 1;
my $status_dir = $cwd;
my $status_dir_passed = 0;
my $status_loop = 0;
my $status_freq = 0;
my $status_mail = 0;
my $check_status = 0;
my $passed : shared = 0;
my $failed : shared = 0;
my $nologfile : shared = 0;
my $running : shared = 0;
my $run_name = "";
my $final_run_path = "";
my $clean_build = 0;
my $all_clean = 0;
my $tbclean = 0;
my $clean_run = 0;
my $error_count = 0;
my $sim_ended = 0;
my $sim_ended_extended = 0;
my $incomplete_run = 0;
my $log_count = 0;
my @error_array = ();
my %error_bin : shared = ();
my %error_bin_count : shared = ();
my $pid;
my @children;
my %pass_count : shared = ();
my %fail_count : shared = ();
my %running_count : shared = ();
my %nologfile_count : shared = ();


my $get_test = 0;
my $testname = "master_test";
my $sltb_opts = "";

my $incr = "";
my $clean = 0;
my $cleanall = 0;
my $glitch = 0;

my $dump = 0;

my $seed_passed = 0;
my $seed_value = 0;

my $rundir = "logs";
my $runpath = "/server/scratch/$user/$project_name$project_version/sim";
my $copy_runpath = "/server/scratch/$user/$project_name$project_version/sim";
my $nocopy = 0;
my $final_rundir = "";
my $get_rundir = 0;

my $legacy = 0;
my $legacy_string = "";

my $get_define = 0;
my $get_builddir = 0;

my $sims_command = "";

my $logfile = "master_test";
my @modified_testname = ();

my $get_seed = 0;
my $msg_lvl = "";
my $get_model_name = 0;
my $uc_model_name = "";
my $get_logid = 0;
my $logID = "";
my $irunOpts = " -c -sv -uvm -access rc -timescale 1ns/1ps -noassert_synth_pragma -vlogext .u -vlogext .vp ";
my $questaOpts = " -sv -timescale 1ns/1ps +libext+u +libext+vp -mfcu -permissive "; #" -c -sv -uvm -access rc -timescale 1ns/1ps -noassert_synth_pragma -vlogext .u ";
my $extra_irunOpts = "";
my $extra_questaOpts = " -permit_unmatched_virtual_intf ";
my $get_dumpstart = 0;
my $get_dumpend = 0;
my $random_seed = 0;

my $flist_passed = 0;
my $flist = "";
# parse the pf_core.vf
# include all the library elements

my $testlist_passed = 0;
my $testlist = "";

my $local_sims = "";
my $number = 1;
my $random_number = int(rand(10000000));


(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime(time);
my $jobname = "$mday$hour$min$sec";

my $INVN_LOCALE = "";
system("/sbin/ifconfig | grep \"Bcast:10.\" | awk '{print \$2}' | awk -F ':' '{print \$2}' > temp");
open(FIND_IP_IDX,"<","temp");
my @FIND_IP = <FIND_IP_IDX>;
close(FIND_IP_IDX);
system("rm -rf temp");
#print "IP is $FIND_IP[0]\n";
my @IP_ADDR = split(/\./,$FIND_IP[0]);
if(($IP_ADDR[0] =~ /10/) && ($IP_ADDR[1] =~ /26/)) 
{
  #print "This is ISJ\n";
  $INVN_LOCALE = "ISJ";
  #setenv INVN_LOCALE "ISJ"
}
if(($IP_ADDR[0] =~ /10/) && ($IP_ADDR[1] =~ /49/)) 
{
  #print "This is ISK\n";
  $INVN_LOCALE = "ISK";
  #setenv INVN_LOCALE "ISK"
}
if(($IP_ADDR[0] =~ /10/) && ($IP_ADDR[1] =~ /5/)) 
{
  #print "This is ISA\n";
  $INVN_LOCALE = "ISA";
  #setenv INVN_LOCALE "ISA"
}

#system("source ./get_locale.csh"); 
if($ENV{'SCRIPTS_RUN_PATH'} eq "")
{
  #$local_sims = "sims";
  if($INVN_LOCALE eq "ISJ")
  {
    $local_sims = "sims";
  }
  elsif($INVN_LOCALE eq "ISA") 
  {
    $local_sims = "sims_shanghai";
  }
  else
  {
    $local_sims = "sims";
  }
}
else
{
  $local_sims = "$ENV{'SCRIPTS_RUN_PATH'}/sims";
}

push(@mail_receiver,"$user\@invensense.com");
foreach my $args (@ARGV)
{
   chomp($args);
   $sims_command .= "$args ";
   if($get_define == 1)
   {
      $get_define = 0;
      $defines .= "+define+$args ";
   }
   if($get_logid == 1)
   {
      $logID = "$args";
      $get_logid = 0;
   }

   if($args =~ /-num_tests=(\d*)/)
   {
       $number = $1;
       $num_tests = "-num_tests=$1 ";
   }
   elsif($args =~ /-var1=(\d*)/)
   {
      $var1 = "-var1=$1 ";
   }
   elsif($args =~ /-var2=(\d*)/)
   {
      $var2 = "-var2=$1 ";
   }
   elsif($args =~ /-var3=(\d*)/)
   {
      $var3 = "-var3=$1 ";
   }
   elsif($args =~ /-var4=(\d*)/)
   {
      $var4 = "-var4=$1 ";
   }
   elsif($args =~ /-var5=(\d*)/)
   {
      $var5 = "-var5=$1 ";
   }
   elsif($args =~ /-fl=(.*)/)
   {
      $flist_passed = 1;
      $flist = $1;
   }
   elsif($args =~ /-f=(.*)/ && $args !~ /-fl/)
   {
      $file_passed = 1;
      $file = $1;
   }
   elsif($args =~ /-cov_merge=(.*)/ && $args !~ /-bargs/)
   {
     $merge_coverage = 1;
     $merge_cov_tool = $1;
   }
   elsif($args =~ /-old_cov_rpt=(.*)/)
   {
     $ena_old_cov_merge = $1;
   }
   elsif($args =~ /-coverage[=(.*)]*/ && $args !~ /-bargs/)
   {
      $coverage = 1;
      my @tmp_cover_args = split(/=/,$args);
      my $tmp_cover_args_size = @tmp_cover_args;
      $complete_coverage_args = $args;
      if($tmp_cover_args_size > 1)
      {
         $coverage_args = $tmp_cover_args[$tmp_cover_args_size-1];
      }
      #print "Coverage args =$coverage_args\n";
   }
   elsif($args =~ /-tl_run/)
   {
      $tl_run = 1;
   }
   elsif($args =~ /-use_old_sims/)
   {
     $local_sims = "/icad/digital/verif/bin/sims_112415";
     print "\nUsing $local_sims for running testcase/regression\n";
   }
   elsif($args =~ /-build/ && $args !~ /-build_/ && $args !~ /-build64/)
   {
      $build = 1;
      $sltb_opts .= " $args ";
      print "BUILD\n";
   }
   elsif($args =~ /-build64/)
   {
      $build = 1;
      $build64 = 1;
      $run64 = 1;
      print "BUILD64";
   }
   elsif($args =~ /-regr=(.*)/)
   {
       $regr = "\U$1";
   }
   elsif($args =~ /-N=(.*)/)
   {
      $postscript = $1;
   }

   elsif($args =~ /-ncv/)
   {
      $whichbuild = "ncv";
      $whichrun = "ncv";
   }
   elsif($args =~ /-vcs/)
   {
      $whichbuild = "vcs";
      $whichrun = "vcs";
      $sltb_opts .= " $args ";
   }
   elsif($args =~ /-questa/ && $args !~ /-questa_/)
   {
      $whichbuild = "questa";
      $whichrun = "questa";
      #$sltb_args .= " $args ";
   }
   elsif($args =~ /-tl=(.*)/)
   {
       $run = 1;
       $testlist_passed = 1;
       $testlist = $1;
   }
   elsif($args =~ /-cpf=(.*)/)
   {
      $cpf_passed = 1;
      $cpf = $1;
   }
   elsif($args =~ /-gui/)
   {
      system("sims_gui.pl &");
      exit(0);
   }
   elsif($args =~ /-upf=(.*)/)
   {
      $upf_passed = 1;
      $upf = $1;
      $questa_upf = " -pa_upf $1 ";
   }
    elsif($args =~ /-debug/)
    {
        $builddebug = 1;
        $sims_dash_args .= "-debug ";
    }
   elsif($args =~ /-ignoresimerror/)
   {
      $ignoresimerror = "-ignoresimerror ";
   }
   elsif($args =~ /-noassert/)
   {
      $noassert = 1;
   }
   elsif($args =~ /-grid/)
   {
      $grid = 1;
      `source /apps/cdn/Util/rtda/2012.09/common/etc/vovrc.csh`;
   }
   elsif($args =~ /-status_freq=(.*)/)
   {
       $status_freq = $1;
   }
   elsif($args =~ /-maxjobs=(.*)/)
   {
      $throttle = $1;
   }
   elsif($args =~ /-maxruntime=(.*)/)
   {
      $max_run_time = $1;
   }
   elsif($args =~ /-p=(.*)/)
   {
      $job_priority = "$1";
   }
   elsif($args =~ /-job_group=(.*)/)
   {
      $job_group = "$1";
   }
   elsif($args =~ /-nowait/)
   {
      $wait = 0;
   }
   elsif($args =~ /-q=(.*)/)
   {
      $job_q = $1;
   }
   elsif($args =~ /-R=(.*)/)
   {
      $resource = " $1";
      #print("resource is $resource\n");
   }
   elsif($args =~ /-incr/)
   {
      $incr = "-incr";
   }
   elsif($args =~ /-pre_script=(.*)/)
   {
      print "Executing pre processing script $1\n";
      system($1);
   }
   elsif($args =~ /-post_script=(.*)/)
   {
      print "Executing post processing script $1\n";
      $post_script = $1;
#      system($1);
   }
   elsif($args =~ /-script=(.*)/)
   {
      print "Will execute script $1 locally/grid before firing off jobs locally/grid\n";
      $script = $1;
   }
   elsif($args =~ /-nocopy/)
   {
      $nocopy = 1;
   }
   elsif($args =~ /-legacy/)
   {
      $legacy = 1;
      $legacy_string = " -legacy ";
      $irunOpts =~ s/-uvm//;
      $irunOpts =~ s/-sv//;
      $questaOpts =~ s/-sv//;
   }

   elsif($args =~ /-mail[=(.*)]*/)
   {
       $nomail = 0;
       $status_mail = 1;
       my $tmp_receiver;
       my @tmp_mail;
       my @tmp_tmp_mail;
       my $tmp_mail_size;
       @tmp_mail = split(/=/,$args);
       $tmp_mail_size = @tmp_mail;
       $tmp_receiver = $tmp_mail[$tmp_mail_size-1];
       @tmp_tmp_mail = split(/,/,$tmp_receiver);
       if($tmp_mail_size > 1)
       {
	      @mail_receiver=Uniquify(@tmp_tmp_mail);
	      $mail_receipients=join(",",@mail_receiver);
         print "Now mail receipients are $mail_receipients\n";
       }else{
	      $mail_receipients="$user\@invensense\.com";
       }
   }
   elsif($args =~ /-rerun_failed/)
   {
      $rerun_failed = 1;
      $rerun_failed_string = " -rerun_failed ";
   }
   elsif($args =~ /-cleanall/)
   {
      $clean = 1;
      $cleanall = 1;
   }
   elsif($args =~ /-clean/)
   {
      $clean = 1;
   }
   elsif($args =~ /-run/ && $args !~ /-run_/ && $args !~ /-run64/)
   {
      $run = 1;
   }
   elsif($args =~ /-run64/)
   {
      # for future
      $run64 = 1;
   }
   elsif($args =~ /-test=(.*)/)
   {
      $testname = $1;
      my @tmp_testname = split(/\//,$testname);
      my $size = @tmp_testname;
      $testname = $tmp_testname[$size-1];
   }
   elsif($args =~ /-run_dir=(.*)/)
   {
      $rundir = $1;
      print "rundir = $rundir\n";
      $separate_run_path = 1;
   }
   elsif($args =~ /-run_path=(.*)/)
   {
      $runpath = $1;
   }
   elsif($args =~ /-dump[=(.*)]*/)
   {
      $dump = 1;
      $dumpopts = "+dump_all +verdi ";
      my @dumpformat;
      my $dumpformatsize;
      @dumpformat = split(/=/,$args);
      $dumpformatsize = @dumpformat;
      if($dumpformatsize > 1)
      {
         my @dumpingoptions = split(/,/,$dumpformat[$dumpformatsize-1]);
         my $dumpingoptsize = @dumpingoptions;
         foreach my $dumps (@dumpingoptions)
         {
            chomp($dumps);
            if($dumps =~ /memory/)
            {
               $simulator_run_args .= " +memory ";
               $qwave_arg .= "+signal+memory=17000,2+cells";
            }
            elsif($dumps =~ /cells/)
            {
               $qwave_arg .= "+signal+cells";
            }
            elsif($dumps =~ /glitch/)
            {
               $qwave_arg .= "+signal+glitch+cells";
               $glitch = 1;
            }
            elsif($dumps =~ /signal/)
            {
               $qwave_arg .= "+signal";
            }
            elsif($dumps =~ /transactions/)
            {
               $qwave_arg .= "+signal+transactions=uvm+cells";
            }
            elsif($dumps =~ /class/)
            {
               $qwave_arg .= "+class";
            }
            elsif($dumps =~ /assertions/)
            {
               $qwave_arg .= "+signal+assertion=pass+cells";
            }
            elsif($dumps =~ /queue/)
            {
               $qwave_arg .= "+signal+queue";
            }
            elsif($dumps =~ /messages/)
            {
               $extra_questaOpts .= "-displaymsgmode both ";
            }
         }
         if($dumpformat[$dumpformatsize-1] eq "evcd" or $dumpformat[$dumpformatsize-1] eq "EVCD")
         {
            $dumpopts .= " +evcd";
         }
      }

      $sltb_opts .= " $args ";
   }
   elsif($args =~ /-dump_start=(.*)/)
   {
      $dumpopts .= " +dump_start=$1 ";
   }
   elsif($args =~ /-dump_end=(.*)/)
   {
      $dumpopts .= " +dump_end=$1 ";
   }
   elsif($args =~ /-set=(.*)/)
   {
      $setname = $1;
   }
   elsif($args =~ /-seed=(.*)/ or $args =~ /-sv_seed=(.*)/)
   {
      $seed_value = $1;
      $simulator_run_args .= " +seed=$1 ";
      $seed_passed = 1;
   }
   elsif($args =~ /-rseed/)
   {
      $random_seed = 1;
   }
   elsif($args =~ /-log/)
   {
      $get_logid = 1;
   }
   elsif($args =~ /-define=(.*)/)
   {
      $get_define = 1;
      $defines .= "+define+$1 ";
      $sltb_opts .= " $1 ";
   }
   elsif($args =~ /-d=(.*)/)
   {
      $get_define = 1;
      $defines .= "+define+$1 ";
      $sltb_opts .= " $args ";
   }
   elsif($args =~ /-model_name=(.*)/)
   {
      $model_name = "$1";
      $uc_model_name = "$1";
   }
   elsif($args =~ /-build_dir=(.*)/)
   {
      $build_dir = "$1";
      print "Setting build_dir = $build_dir\n";
   }
   elsif($args =~ /-build_path=(.*)/)
   {
      $build_path = "$1";
      print "Setting build_path = $build_path\n";
   }
   elsif($args =~ /-norun/)
   {
      $run = 0;
      $run64 = 0;
   }
   elsif($args =~ /-nobuild/)
   {
      $nobuild = 1;
   }
   elsif($args =~ /-SDA=(.*)/)
   {
       my @tmpsda = split(/,/,$1);
       foreach my $sda (@tmpsda)
       {
           $simulator_dash_args .= "$sda ";
       }
   }
   elsif($args =~/-irun_b_opts=(.*)/)
   {
      $irunOpts .= " $1 ";
   }
   elsif($args =~ /-irun_r_opts=(.*)/)
   {
      $extra_irunOpts .= " $1 ";
   }
   elsif($args =~ /-questa_b_opts=(.*)/)
   {
      $questaOpts .= " $1 ";
      print "Options passed are $1\n";
   }
   elsif($args =~ /-questa_r_opts=(.*)/)
   {
      $extra_questaOpts .= " $1 ";
   }
   elsif($args =~ /-questa_elab_opts=(.*)/)
   {
      $questa_elab_opts .= " $1 ";
   }
   elsif($args =~ /-questa_vopt_args=(.*)/)
   {
      $questa_vopt_args .= " $1 ";
   }

   elsif($args =~ /-bargs=(.*)/)
   {
      $irunOpts .= " $1 ";
      $questaOpts .= " $1 ";
   }
   elsif($args =~ /-rargs=(.*)/)
   {
      $extra_irunOpts .= " $1 ";
      $extra_questaOpts .= " $1 ";
   }
   elsif($args =~ /-oargs=(.*)/)
   {
      $questa_vopt_args .= " $1 ";
      $irunOpts .= " $1 ";
   }
   elsif($args =~ /-eargs=(.*)/)
   {
      $questa_elab_opts .= " $1 ";
      $irunOpts .= " $1 ";
   }

   elsif($args =~ /-h/ or $args =~ /-help/)
   {
      &help();
      exit(0);
   }
   elsif($args =~ /\+seed=(.*)/)
   {
      $seed_passed = 1;
      $seed_value = $1;
      $simulator_run_args .= "$args ";
   }
   elsif($args =~ /-status[=(.*)]*/ && $args !~ /status_/ && $args !~ /_status/)
   {
       $check_status = 1;
       $run = 0;
       my @tmpstatusdir;
       my $tmpstatussize;
       @tmpstatusdir = split(/=/,$args);
       $tmpstatussize = @tmpstatusdir;
       if($tmpstatussize > 1)
       {
           $status_dir = $tmpstatusdir[$tmpstatussize-1];
           $status_dir_passed = 1;
       }
   }
   elsif($args =~ /-status_dir=(.*)/)
   {
       $status_dir = $1;
       $status_dir_passed = 1;
   }
   elsif($args =~ /-status_loop/)
   {
       $status_loop = 1;
   }
   elsif($args =~ /-status_mail/)
   {
       $status_mail = 1;
   }
   elsif($args =~ /-min_status/)
   {
      $min_status = 1;
   }
   elsif($args =~ /-(.*)[=(.*)]*/)
   {
       print "WARNING:Unrecognized sims option -$1\n";
       print "Will be treated as a simulator argument\n";
       $simulator_dash_args = "\"-$1";
       if($2 != "")
       {
           $simulator_dash_args .= "=$2";
       }
       $simulator_dash_args .= "\"";
   }

   elsif($args =~ /\+/)
   {
      $simulator_run_args .= "$args ";
   }
}

if($tbroot eq "" && $check_status == 0)
{
   die("\$TB_ROOT not set. Quitting...\n");
}
if($rtlroot eq "" && $check_status == 0)
{
   die("\$RTL_ROOT not set. Quitting...\n");
}
$build_dir = "$build_path/$build_dir";
print "New build_dir is $build_dir\n";
if($clean == 1)
{
   if($cleanall == 1)
   {
      system("rm *_status");
   }
   if(-e "temp.fl")
   {
      system("rm temp.fl");
   }
   if(-e "rerun")
   {
      system("rm rerun");
   }
   if(-e "sims_rerun")
   {
      system("rm sims_rerun");
   }
   if(-e "perlfile.pl")
   {
      system("rm perlfile.pl");
   }
   if(-e "perltest")
   {
      system("rm perltest");
   }
   system("*.log");
   if(-d $runpath)
   {
      system("rm $runpath/*");
   }
   if(-d "$build_dir/INCA_$model_name")
   {
      system("rm -rf $build_dir/INCA_$model_name");
   }
}
my $current_dir = "";
my $total_runs = 0;
my $seen_log = 0;

if($noassert == 1)
{
   $extra_questaOpts .= " -nosva -noimmedassert ";
   $extra_irunOpts .= " -noassert ";
}

system("mkdir -p $runpath");
if($runpath =~ /scratch/ && $runpath !~ /server/) # If there is a server, its already been replaced
{
# regression/test being run on scratch
  my $machine = `uname -a`;
  my @machine_arr = split(/ /,$machine);
  foreach my $mac (@machine_arr)
  {
	if($mac =~ /iuseng/)
	{
	  my @cut_mac = split(/\./,$mac);
	  $runpath =~ s/scratch/server\/$cut_mac[0]\_scratch/g;
	}
  }
}
elsif($runpath eq ".")
{
   $runpath = getcwd();
   if($runpath =~ /scratch/)
   {
      # regression/test being run on scratch
      my $machine = `uname -a`;
      my @machine_arr = split(/ /,$machine);
      foreach my $mac (@machine_arr)
      {
         if($mac =~ /iuseng/)
         {
            my @cut_mac = split(/\./,$mac);
            $runpath =~ s/scratch/server\/$cut_mac[0]\_scratch/g;
         }
      }
   }
}
sub do_status_check
{
    open(STATUS,">","tmp_status");
#    print("Current WD = $ENV{'PWD'}\n");
#    system("ls $status_dir | grep $block_name\_run >> tmp_status");
#    system("ls $status_dir | grep test_ >> tmp_status");
    system("ls $status_dir >> tmp_status");
    if($force == 1)
    {
        print "status forced\n";
        system("ls $status_dir > tmp_status");
    }
#    system("ls $block_name\_run* | grep >> tmp_status");
close(STATUS);
open(STATUS,"<","tmp_status");
if($status_dir_passed == 1)
{
    open(STATUSFILE,">","$status_dir\_regr_status");
    open(PASSINGSTATUS,">","$status_dir\_passing_status");
#    open(STATUSFILE,">","$cwd/$block_name\_regr_status");
#    open(PASSINGSTATUS,">","$cwd/$block_name\_passing_status");
}
else
{
    open(STATUSFILE,">","$cwd/$block_name\_regr_status");
    open(PASSINGSTATUS,">","$cwd/$block_name\_passing_status");
}

if($merge_coverage)
{
  open(COVCMD,">","$status_dir\_coverage_cmd");
}

my $line = 0;
## Take this 200 threads at a time. Might make it much faster
my @files;
my @l2_dirs;
my @l2_files;
my @l3_dirs;
my @l3_files;
my @l4_dirs;
my @l4_files;
my @l5_dirs;
my @l5_files;
my %l3_dirs_map = ();
my %l4_dirs_map = ();

## What if the first level is a file itself
$seen_log = 0;
while(<STATUS>)
{
    chdir($cwd);
    chomp($_);
    $_ =~ s/://;
    if($_ =~ /\.log/ && $_ !~ /old/ && $_ !~ /tr_db/ && $_ !~ /tarmac/)
    {
        &process_files("$status_dir/$_");
        $seen_log = 1;
        next;
    }
        if(opendir(DIR,"$status_dir/$_")) ## Open the directories one by one
        {
            push(@files,readdir(DIR));
            closedir(DIR);
        }
        foreach my $f (@files) ## GO through the first level files
        {
#            my @flist = map {$_} glob("*.log","wrapper_runtest.o*","session.cmd.o*");
            $current_dir = "$status_dir/$_";
            next if(($f eq ".") || ($f eq ".."));
            if(-d "$current_dir/$f") ## If we encounter another directory, push it in
            {
                push(@l2_dirs,$f);
            }
            else
            {
                &process_files("$status_dir/$_/$f");
                if($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/) {
                    $seen_log = 1;
                }
            }
            if(($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/) && (($seen_log == 1))) {
                next;
            }

        }

        ## Going into the next level. Change directory to that level
        foreach my $dirs (@l2_dirs) ## level 2 directories
        {
            $current_dir = "$status_dir/$_/$dirs";
            $seen_log = 0;
            @l2_files = ();
#            print "Second level directory is $current_dir\n";
            next if(($dirs eq ".") || ($dirs eq ".."));
            if(opendir(DIR,$current_dir))
            {
                push(@l2_files,readdir(DIR));
                closedir(DIR);
            }
            foreach my $f (@l2_files)
            {
                if(($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/) && (($seen_log == 1)))
                {
                    next;
                }

                next if(($f eq ".") || ($f eq ".."));
                if(-d "$current_dir/$f") ## What if $dirs is yet another directory
                {
                    my $tmp = "$current_dir/$f";
                    push(@l3_dirs,$tmp);
                    $l3_dirs_map{$tmp} = $current_dir;
                }
                else
                {
                    &process_files("$current_dir/$f");
                    if($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/)
                    {
                        $seen_log = 1;
                    }
                }
            }

        }

        my @split_dir = ();
        my $size_split = 0;
        foreach my $dirs (@l3_dirs) ## level 3 directories
        {
            @split_dir = split(/\//,$dirs);
            $size_split = @split_dir;
            $current_dir = "$l3_dirs_map{$dirs}/$split_dir[$size_split-1]";
            $seen_log = 0;
            @l3_files = ();
            next if(($dirs eq ".") || ($dirs eq ".."));
            if(opendir(DIR,$dirs))
            {
                push(@l3_files,readdir(DIR));
                closedir(DIR);
            }
            foreach my $f (@l3_files)
            {
                if(($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/) && ($seen_log == 1))
                {
                    next;
                }

                next if(($f eq ".") || ($f eq ".."));
                if(-d "$current_dir/$f")
                {
                    my $tmp = "$current_dir/$f";
                    push(@l4_dirs,$tmp);
                    $l4_dirs_map{$tmp} = $current_dir;
                }
                else
                {
                    &process_files("$current_dir/$f");
                    if($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/)
                    {
                        $seen_log = 1;
                    }
                }
            }

            @split_dir = ();
        }

        @split_dir = ();
        foreach my $dirs (@l4_dirs) ## level 2 directories
        {
            @split_dir = split(/\//,$dirs);
            $size_split = @split_dir;
            $current_dir = "$l4_dirs_map{$dirs}/$split_dir[$size_split-1]";
            $seen_log = 0;
            @l4_files = ();
            next if(($dirs eq ".") || ($dirs eq ".."));
            if(opendir(DIR,$dirs))
            {
                push(@l4_files,readdir(DIR));
                closedir(DIR);
            }
            foreach my $f (@l4_files)
            {
                if(($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/) && ($seen_log == 1))
                {
                    next;
                }

                next if(($f eq ".") || ($f eq ".."));
                if(-d "$current_dir/$f")
                {
                    push(@l5_dirs,$f);
                }
                else
                {
                    &process_files("$current_dir/$f");
                    if($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/)
                    {
                        $seen_log = 1;
                    }
                }
            }

            @split_dir = ();
        }

            @split_dir = ();
        foreach my $dirs (@l5_dirs) ## level 2 directories
        {
            $current_dir .= "/$dirs";
            $seen_log = 0;
            @l5_files = ();
            next if(($dirs eq ".") || ($dirs eq ".."));
            if(opendir(DIR,$dirs))
            {
                push(@l5_files,readdir(DIR));
                closedir(DIR);
            }
            foreach my $f (@l5_files)
            {
                if(($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/) && ($seen_log == 1))
                {
                    next;
                }

                next if(($f eq ".") || ($f eq "..") || (-d $f));
                &process_files("$current_dir/$f");
                if($f =~ /\.log/ && $f !~ /old/ && $f !~ /tr_db/ && $_ !~ /tarmac/)
                {
                    $seen_log = 1;
                }
            }

        }
        $current_dir = "";
        @files = ();
        @l2_dirs = ();
        @l2_files = ();
        @l3_dirs = ();
        @l3_files = ();
        @l4_dirs = ();
        @l4_files = ();
        @l5_dirs = ();
        @l5_files = ();
        %l3_dirs_map = ();
        %l4_dirs_map = ();



        $line += 1;
        if(($line % 20) == 0)
        {
            foreach my $tid (@children)
            {
                my $tmp = $tid->join;
            }
            if(defined @children)
            {
                @children = ();
            }
        }
   }
    foreach(@children)
    {
        my $tmp = $_->join;
    }

#    print STATUSFILE "RUN DIRECTOR(Y/IES)\n\n";
#    print STATUCFILE "$cwd\n\n";
    foreach my $fail_key(keys %fail_count)
    {
#        print STATUSFILE "$fail_count{$fail_key}\n";
#        my @fail_array = split(/\n/,$fail_count{$fail_key});
#        my $fail_size = @fail_array;
#        if($fail_size == 1)
#        {
#            push @{$fail_bucket{$fail_array[0]}},$fail_key;
#        }
#        else
#        {
#            foreach my $errors (@fail_array)
#            {
#                if($errors =~ /ERRORS=/)
#                {
#                    push @{$fail_bucket{'FSIM MISCOMPARE'}},$fail_key;
#                }
#            }
#        }
        $failed += 1;
    }

    foreach my $pass_key(keys %pass_count)
    {
        print STATUSFILE "$pass_key\n\n";
        $passed += 1;
    }
    my $first_error = "";
    foreach my $running_key(keys %running_count)
    {
        $running += 1;
    }
    foreach my $nologfile_key(keys %nologfile_count)
    {
        $nologfile += 1;
    }

    print STATUSFILE "\n\n";
    if($status_dir_passed == 1)
    {
        print STATUSFILE "Run Directory $status_dir\n";
    }
    else
    {
        print STATUSFILE "Run Directory $cwd\n";
    }
    print STATUSFILE "\n\n\n\t    \U$block_name REGRESSION STATUS\n";
    print STATUSFILE "\t-----------------------------------\n\n";
    print STATUSFILE "\tPASSED\t\t\t$passed\n";
    print STATUSFILE "\tFAILED\t\t\t$failed\n";
    print STATUSFILE "\tSTILL RUNNING\t\t$running\n";
    print STATUSFILE "\tNOT YET RUN\t\t\t$nologfile\n";
    print STATUSFILE "===============================================================\n";
    $total_runs = $passed+$failed+$running+$nologfile;
    print STATUSFILE "\tTOTAL RUNS FIRED\t\t$total_runs\n\n\n";

    my $numdir = `ls $status_dir | wc -l`;
    my $numleft = $numdir-$total_runs;
#    print STATUSFILE "\tTOTAL RUNS LEFT\t\t$numleft\t\t\n\n";

    print STATUSFILE "\n\n\n\n";
    print STATUSFILE "BUCKETS FOR FAILING TESTS\n";
    print STATUSFILE "==========================\n\n";
    my $bucket_count = 1;
    foreach my $error_bin_key(keys %error_bin)
    {
        print STATUSFILE "$bucket_count)$error_bin_key \($error_bin_count{$error_bin_key} test\(s\)\)\n";
        $bucket_count++;
    }

    print STATUSFILE "\n\n";
    print STATUSFILE "LIST OF FAILED TESTS\n";
    print STATUSFILE "======================\n";
    foreach my $fail_key(keys %fail_count)
    {
        print STATUSFILE "$fail_key\n\n";
#        print STATUSFILE "$fail_count{$fail_key}\n";
#        my @fail_array = split(/\n/,$fail_count{$fail_key});
#        my $fail_size = @fail_array;
#        if($fail_size == 1)
#        {
#            push @{$fail_bucket{$fail_array[0]}},$fail_key;
#        }
#        else
#        {
#            foreach my $errors (@fail_array)
#            {
#                if($errors =~ /ERRORS=/)
#                {
#                    push @{$fail_bucket{'FSIM MISCOMPARE'}},$fail_key;
#                }
#            }
#        }
    }
#    print STATUSFILE "\n\n";
    print PASSINGSTATUS "LIST OF PASSING TESTS\n";
    print PASSINGSTATUS "======================\n";
    if($merge_coverage)
    {
      if(($merge_cov_tool =~ "imc") || ($merge_cov_tool =~ "iccr"))
      {
        print COVCMD "merge \\\n";
        if($ena_old_cov_merge)
        {
          print COVCMD "\$env(TB_ROOT)/merge_coverage/final_merge_$merge_cov_tool \\\n";
        }
      }
    }

    foreach my $pass_key(keys %pass_count)
    {
      print PASSINGSTATUS "$pass_key\n\n";
      if($merge_coverage)
      {
        my @pass_test_1 = split(/\.log/,$pass_key);
        my @pass_test = split(/\//,$pass_test_1[0]);
        if($merge_cov_tool =~ "vcover")
        {
          print COVCMD "$status_dir/$pass_test[@pass_test -2]/*.ucdb \\\n";
        }
        else
        {
          print COVCMD "$status_dir/$pass_test[@pass_test -2]/cov_work/scope/* \\\n";
        }
      }
    }
    if($merge_coverage)
    {
      if($merge_cov_tool =~ "iccr")
      {
        print COVCMD "-out \$env(TB_ROOT)/merge_coverage/merge_cov_$merge_cov_tool";
      }
      if($merge_cov_tool =~ "imc")
      {
        print COVCMD "-out \$env(TB_ROOT)/merge_coverage/merge_cov_$merge_cov_tool \\\n";
        print COVCMD "-metrics all -overwrite";
      }
      if($merge_cov_tool =~ "vcover")
      {
        print COVCMD "\n";
      }
    }
    print STATUSFILE "\n\n";
    print STATUSFILE "LIST OF INCOMPLETE/NON STARTED TESTS\n";
    print STATUSFILE "======================================\n";
    foreach my $running_key(keys %running_count)
    {
        print STATUSFILE "$running_key\n\n";
    }
    foreach my $nologfile_key(keys %nologfile_count)
    {
        print STATUSFILE "$nologfile_key :\n";
    }

    print STATUSFILE "\n\n";
    print STATUSFILE "BUCKETS BY TESTS\n";
    print STATUSFILE "=================\n\n";
    foreach my $error_bin_key(keys %error_bin)
    {
        print STATUSFILE "BUCKET >> $error_bin_key\n";
        print STATUSFILE $error_bin{$error_bin_key};
        print STATUSFILE "\n\n";
    }


    close(STATUS);
    close(STATUSFILE);
    close(PASSINGSTATUS);
    if($merge_coverage)
    {
      close(COVCMD);
    }
#    system("rm tmp_status");
    if($min_status == 0)
    {
      if($status_dir_passed == 1)
      {
         print "\n\nRun Directory $status_dir";
      }
      else
      {
         print "\n\nRun Directory $cwd";
      }
      print "\n\n\n\t    \U$block_name REGRESSION STATUS\n";
      print "\t-----------------------------------\n\n";
      print "\tPASSED\t\t\t$passed\n";
      print "\tFAILED\t\t\t$failed\n";
      print "\tSTILL RUNNING\t\t$running\n";
      print "\tNOT YET RUN\t\t$nologfile\n";
      print "===============================================================\n";
      print "TOTAL RUNS FIRED\t\t$total_runs\n";

      print "\n\n";
      print "BUCKETS FOR FAILING TESTS\n";
      print "==========================\n";
   }
   $bucket_count = 1;
   foreach my $error_bin_key(keys %error_bin)
   {
      if($min_status == 0)
      {
         print "$bucket_count)$error_bin_key \($error_bin_count{$error_bin_key} test\(s\)\)\n";
      }
      else
      {
         print "\t\t************ TEST FAILED ************\n";
         print "\t\tFAILURE SIGNATURE : $error_bin_key\n\n";
      }
      $bucket_count++;
   }
   if($min_status == 1 && $passed > 0)
   {
      print("\t\t*************** TEST PASSED ***************\n");
   }

   if($min_status == 0)
   {
      print "\n\n";

#    print "TOTAL RUNS LEFT\t\t\t$numleft\n\n";
      if($status_dir_passed == 1)
      {
         print "Status details in $status_dir\_regr_status ; List of Passing tests in $status_dir\_passing_status\n";
      }
      else
      {
         print "Status details in $status_dir/$block_name\_regr_status ; List of Passing tests in $status_dir/$block_name\_passing_status\n";
      }
   }
}

if($check_status == 1)
{
   $run = 0;
#   print("CWD = $ENV{'PWD'}\n");
   chdir($ENV{'PWD'});
    $num_dirs = `ls $status_dir | wc -l`;
    if($status_loop == 1)
    {

        &do_status_check();
        #system("sims -status=$status_dir -status_loop -status_mail");
        if($status_mail == 1)
        {
            if($status_dir_passed == 1)
            {
               system("cat $status_dir\_regr_status | mail -s \"Regression Status\" $mail_receipients ");
            }
            else
            {
               system("cat $status_dir/$block_name\_regr_status | mail -s \"Regression Status\" $mail_receipients ");
            }
        }
        $failed += `bjobs -w | grep Failed`;
        $running += `bjobs -w | grep RUN |wc -l`;
        $total_runs = $passed+$failed+$running+$nologfile;

        my $numdir = `ls $status_dir | wc -l`;
        my $numleft = $numdir-$total_runs;
        system("showenv.pl");

        ## What if numleft > 0 or running > 0 and bjobs -w says there are no jobs (ERROR CASE)
        my $ncjobs = `bjobs -w | grep -v Done | grep -v Failed`;
        chomp($ncjobs);
        if($ncjobs eq "")
        {
            $numleft = 0;
            $running = 0;
        }
        while(($numleft > 0) || ($running > 0))
        {
            if($status_freq == 0)
            {
                sleep(1200); ## Sleep for 20 mins
            }
            else
            {
                my $sleep_freq = 60*($status_freq);
                sleep($sleep_freq);
            }
            ##system("sims -status=$status_dir -status_loop -status_mail > /dev/null &")
            #&do_status_check();
#            if($status_mail == 1)
#            {
                print("$local_sims -status=$status_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string\n");
                system("$local_sims -status=$status_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string");
                exit(0);
#            }
        }
        ## Fire off rerun_grid_dump from each of the failing directories
        my $got_line;
        my $dir_to_fire;
        open(TMP1,">","tmp_fail_list");
        foreach my $error_bin_key (keys %error_bin)
        {
            print TMP1 $error_bin{$error_bin_key};
            next if($error_bin_key =~ "Incomplete");
            open(TMP,">","tmp_fire");
            print TMP $error_bin{$error_bin_key};
            close(TMP);
            open(TMP,"<","tmp_fire");
            while(<TMP>)
            {
                next if($got_line == 1);
                $dir_to_fire = $_;
                $got_line = 1;
            }
            close(TMP);
            if($dir_to_fire =~ /scratch/)
            {
               # regression/test being run on scratch
               my $machine = `uname -a`;
               my @machine_arr = split(/ /,$machine);
               foreach my $mac (@machine_arr)
               {
                  if($mac =~ /iuseng/)
                  {
                     $dir_to_fire =~ s/scratch/server\/$mac\_scratch/g;
                  }
               }
            }

            my @split_file_names = split(/\//,$dir_to_fire);
            my $file_names_size = @split_file_names;
            $split_file_names[$file_names_size-1] = "";
            my $tmp_dir_to_fire = join('/',@split_file_names);
            $dir_to_fire = $tmp_dir_to_fire;
            chomp($dir_to_fire);
            #print "CHDIR = $dir_to_fire\n";
            if($rerun_failed == 1)
            {
                chdir($dir_to_fire);
#            my $run_exe = "$dir_to_fire\rerun_grid_dump";
                system("rerun_grid_dump");
                chdir($cwd);
                $got_line = 0;
            }
        }
        close(TMP1);
        open(TMP1,"<","tmp_fail_list");
        if(-e "regr_fail.tl")
        {
            system("rm regr_fail.tl");
        }
        while(<TMP1>)
        {
            my $tmp_fail_dir = $_;
            $tmp_fail_dir =~ s/\/*.log//;
            chomp($tmp_fail_dir);
            $tmp_fail_dir = $cwd."/$tmp_fail_dir";
            $tmp_fail_dir .= "sims_command";
            system("head $tmp_fail_dir >> regr_fail.tl");
        }
        close(TMP1);
        if(-e "tmp_fire")
        {
            system("rm tmp_fire");
        }
    }
    else
    {
        &do_status_check();
        my $got_line;
        my $dir_to_fire;
        open(TMP1,">","tmp_fail_list");
        foreach my $error_bin_key (keys %error_bin)
        {
            print TMP1 $error_bin{$error_bin_key};
            next if($error_bin_key =~ "Incomplete");
            open(TMP,">","tmp_fire");
            print TMP $error_bin{$error_bin_key};
            close(TMP);
            open(TMP,"<","tmp_fire");
            while(<TMP>)
            {
                next if($got_line == 1);
                $dir_to_fire = $_;
                $got_line = 1;
            }
            close(TMP);
            if($dir_to_fire =~ /scratch/)
            {
               # regression/test being run on scratch
               my $machine = `uname -a`;
               my @machine_arr = split(/ /,$machine);
               foreach my $mac (@machine_arr)
               {
                  if($mac =~ /iuseng/)
                  {
                     $dir_to_fire =~ s/scratch/server\/$mac\_scratch/g;
                  }
               }
            }

            my @split_file_names = split(/\//,$dir_to_fire);
            my $file_names_size = @split_file_names;
            $split_file_names[$file_names_size-1] = "";
            my $tmp_dir_to_fire = join('/',@split_file_names);
            $dir_to_fire = $tmp_dir_to_fire;
            chomp($dir_to_fire);
            #print "CHDIR = $dir_to_fire\n";
            if($rerun_failed == 1)
            {
               print "Submitting failed test under $dir_to_fire\n";
               chdir($dir_to_fire);
#            my $run_exe = "$dir_to_fire\rerun_grid_dump";
               system("rerun_grid_dump");
               chdir($cwd);
               $got_line = 0;
            }
        }
        close(TMP1);

        if($status_mail == 1)
        {
            if($status_dir_passed == 1)
            {
                foreach my $receivers (@mail_receiver)
                {
                    print "Sending Email to $receivers\n";
                    system("mail -s \"$block_name Regression Status\" $receivers < $cwd/$status_dir\_regr_status");
                }
            }
            else
            {
                foreach my $receivers (@mail_receiver)
                {
                    print "Sending Email to $receivers\n";
                    system("mail -s \"$block_name Regression Status\" $receivers < $status_dir/$block_name\_regr_status");
                }
            }
        }
    }
    if($merge_coverage)
    {
      #my $file_name = "$status_dir\_coverage_cmd.cmd";
      #print "Parsing input file $file_name \n";
      #system("\n\ndos2unix $file_name");
      #open (I_FILE , "<$file_name") || die "Input File not found.\n";
      #my @lines = <I_FILE>;
      #close (I_FILE);
      #print "vcover merge merge_rpt @lines";
      print "coverage command file $status_dir\_coverage_cmd\n";
      if($merge_cov_tool =~ "iccr")
      {
        system("iccr $status_dir\_coverage_cmd");
      }
      if($merge_cov_tool =~ "imc")
      {
        system("imc -exec $status_dir\_coverage_cmd");
      }
      if($merge_cov_tool =~ "vcover")
      {
        my $file_name = "$status_dir\_coverage_cmd";
        print "Parsing input file $file_name \n";
        system("\n\ndos2unix $file_name");
        open (I_FILE , "<$file_name") || die "Input File not found.\n";
        my @lines = <I_FILE>;
        close (I_FILE);
        if($ena_old_cov_merge)
        {
          system("vcover merge -out \$TB_ROOT/merge_coverage/merge_cov_$merge_cov_tool.ucdb \$TB_ROOT/merge_coverage/final_merge_$merge_cov_tool.ucdb @lines");
        }
        else
        {
          system("vcover merge -out \$TB_ROOT/merge_coverage/merge_cov_$merge_cov_tool.ucdb @lines");
        }
      }
    }
    exit(0);
}
sub submit_grid_jobs
{
   my $local_job_pr = $_[0];
   my $local_job_gr = $_[1];
   my $local_job_q = $_[2];
   my $local_job_set = $_[3];
   my $local_throttle = $_[4];
   my $local_resource = $_[5];
   my $local_runcmd = $_[6];
   print("Submitting bsub \"$local_runcmd\"");
   my $lsf_job_group = $local_job_gr;
   my $lsf_job_limit = $local_throttle;
   my $lsf_run_time = $_[7];
   #print("\nJob group is $lsf_job_group");
   #print("\nJob limit is $lsf_job_limit\n");

   my $bgcmd = 'bgadd';
   my $job_group_command = "${bgcmd} -L ${lsf_job_limit} ${lsf_job_group} 2>&1";
   my $answer = `$job_group_command`;
   #print "\nAnswer is $answer\n";
   if ($answer =~ / Group exists\n$/) {
     my $bgcmd = 'bgmod';
     my $job_group_command = "${bgcmd} -L ${lsf_job_limit} ${lsf_job_group} 2>&1";
     my $answer = `$job_group_command`;
     #print "\n2nd Answer is $answer\n";
     if ($answer !~ / is modified\.\n$/) {
       my $msg="";
       $msg .= "***ERROR: ";
       $msg .= "Could neither add nor modify job group ${lsf_job_group}\n";
       die ($msg);
     }
   }

   #system("bsub -R "rusage[Verilog=1]" 'nc run -p $local_job_pr $local_job_gr -C $local_job_q -set $local_job_set -D -limit $user $local_throttle -r $local_resource -- \"$local_runcmd\"'");
   if($whichrun eq "ncv")
   {
     system("bsub -q \"$local_job_q\" -R \"rusage[Incisive=1:duration=1]\" -J \"$setname\" -g \"$lsf_job_group\" -W \"$lsf_run_time\" -o \"bsub_cmd.txt\" '$local_runcmd'");
   }
   elsif($whichrun eq "questa")
   {
     system("bsub -q \"$local_job_q\" -R \"rusage[Verilog=1:duration=1]\" -J \"$setname\" -g \"$lsf_job_group\" -W \"$lsf_run_time\" -o \"bsub_cmd.txt\" '$local_runcmd'");
   }
   elsif($whichrun eq "vcs")
   {
     system("bsub -q \"$local_job_q\" -R \"rusage[duration=1]\" -J \"$setname\" -g \"$lsf_job_group\" -W \"$lsf_run_time\" -o \"bsub_cmd.txt\" '$local_runcmd'");
   }
   else
   {
     print "\n\nNot able to found proper tool to launch jobs \n\n";
   }
}
sub bin_group
{
    my $msg = $_[0];
    my $file = $_[1];
    print "Msg is: $msg\n";
    if($msg =~ "Assembler Error") {
	 $error_bin{'AssemblerError'} .= "$file\n";
        $error_bin_count{'AssemblerError'}++;
    }
    elsif($msg =~ "TEST END: MAX TIMEOUT ERROR"){
#        if($fsimmsg =~ "FSIM MODEL COMPARE FAILED") {
#	        $error_bin{'ModelMismatch_wMaxTimeoutError '} .= "$file\n";
#        }else{
           $error_bin{'MaxTimeOutError'} .= "$file\n";
        $error_bin_count{'MaxTimeOutError'}++;
#        }
    }
    elsif($msg =~ "INTERR: INTERNAL EXCEPTION"){
        $error_bin{'INTERNAL EXCEPTION'} .= "$file\n";
        $error_bin_count{'INTERNAL EXCEPTION'}++;
    }
    elsif($msg =~ "HANG EXIT ERR") {
	 $error_bin{'HangExitError'} .= "$file\n";
        $error_bin_count{'HangExitError'}++;
    }
    elsif($msg =~ "Watch Dog timer exceeds") {
	 $error_bin{'HangExitError'} .= "$file\n";
        $error_bin_count{'HangExitError'}++;
    }
    elsif($msg =~ "simulation hang") {
	 $error_bin{'HangExitError'} .= "$file\n";
        $error_bin_count{'HangExitError'}++;
    }
    elsif($msg =~ "HANG TIMEOUT ERR") {
	 $error_bin{'HangTimeOutError'} .= "$file\n";
        $error_bin_count{'HangTimeOutError'}++;
    }
    elsif($msg =~ "MAX TIMEOUT ERR") {
	 $error_bin{'MaxTimeOutError'} .= "$file\n";
        $error_bin_count{'MaxTimeOutError'}++;
    }
    elsif($msg =~ "SVA_FATAL")
    {
        $error_bin{'SVA_FATAL_ERROR'} .= "$file\n";
        $error_bin_count{'SVA_FATAL_ERROR'}++;
    }
    elsif($msg =~ "ARCH REG MISMATCH") {
	 $error_bin{'ArchPCMismatch'} .= "$file\n";
        $error_bin_count{'ArchPCMismatch'}++;
    }
    elsif($msg =~ "Fatal Internal Error") {
	 $error_bin{'FatalSimulatorError'} .= "$file\n";
        $error_bin_count{'FatalSimulatorError'}++;
    }
    elsif($msg =~ "Fatal Error") {
	 $error_bin{'FatalSimulatorError'} .= "$file\n";
        $error_bin_count{'FatalSimulatorError'}++;
    }
    elsif($msg =~ "Simulator Error") {
	 $error_bin{'FatalSimulatorError'} .= "$file\n";
        $error_bin_count{'FatalSimulatorError'}++;
    }
    elsif($msg =~ "Address order violation") {
	 $error_bin{'AddressOrderViolation'} .= "$file\n";
        $error_bin_count{'AddressOrderViolation'}++;
    }
    elsif($msg =~ "Load order violation") {
	 $error_bin{'LoadOrderViolation'} .= "$file\n";
        $error_bin_count{'LoadOrderViolation'}++;
    }
    elsif($msg =~ " Store order violation") {
	 $error_bin{'StoreOrderViolation'} .= "$file\n";
        $error_bin_count{'StoreOrderViolation'}++;
    }
    elsif($msg =~ "order violation") {
	 $error_bin{'MemoryOrderViolation'} .= "$file\n";
        $error_bin_count{'MemoryOrderViolation'}++;
    }
    elsif($msg =~ "Forbidden_assertion") {
	 $error_bin{'Forbidden_Error'} .= "$file\n";
        $error_bin_count{'Forbidden_Error'}++;
    }
    elsif($msg =~ "Assertion error")
    {
	   $error_bin{'Assertion'} .= "$file\n";
      $error_bin_count{'Assertion'}++;
    }
    elsif($msg =~ "ncsim")
    {
        if($msg =~ /Assertion/)
        {
           $error_bin{'Assertion'} .= "$file\n";
           $error_bin_count{'Assertion'}++;
        }
        else
        {
            $error_bin{'Simulator_Error'} .= "$file\n";
            $error_bin_count{'Simulator_Error'}++;
         }
    }
    elsif($msg =~ "OneHot_assertion") {
	 $error_bin{'Onehot_Error'} .= "$file\n";
        $error_bin_count{'Onehot_Error'}++;
    }
    elsif($msg =~ "ZeroHot_assertion") {
	 $error_bin{'ZeroHot_Error'} .= "$file\n";
        $error_bin_count{'ZeroHot_Error'}++;
    }
    elsif($msg =~ "Timeout_assertion") {
	 $error_bin{'Timeout_assertion'} .= "$file\n";
        $error_bin_count{'Timeout_assertion'}++;
    }
    elsif($msg =~ "BAADBEEF Failure") {
	 $error_bin{'BAADBEEF_Failure'} .= "$file\n";
        $error_bin_count{'BAADBEEF_Failure'}++;
    }
    elsif($msg =~ "Completion TID Mismatch") {
	 $error_bin{'MAPCompletion_Error'} .= "$file\n";
        $error_bin_count{'MAPCompletion_Error'}++;
    }
    elsif($msg =~ "MUX MUTEX VIOLATION") {
	 $error_bin{'Mux_Mutex_Error'} .= "$file\n";
        $error_bin_count{'Mux_Mutex_Error'}++;
    }
    elsif($msg =~ "MUX VIOLATION")
    {
	 $error_bin{'Mux_Mutex_Error'} .= "$file\n";
        $error_bin_count{'Mux_Mutex_Error'}++;
    }
    elsif($msg =~ "BIU BMI DATA CONSISTENCY") {
	 $error_bin{'BiuBmiDataConsistency'} .= "$file\n";
        $error_bin_count{'BiuBmiDataConsistency'}++;
    }
    elsif($msg =~ "BIU BSI DATA CONSISTENCY") {
	 $error_bin{'BiuBsiDataConsistency'} .= "$file\n";
        $error_bin_count{'BiuBsiDataConsistency'}++;
    }
    elsif($msg =~ "IO ORDERING VIOLATION") {
	 $error_bin{'IoOrderViolation'} .= "$file\n";
        $error_bin_count{'IoOrderViolation'}++;
    }
    elsif($msg =~ "[TERMINATE]")
    {
        my @split_msg = split(/:/,$msg);
        my $split_msg_size = @split_msg;
        my $act_msg = "";
        if($split_msg_size == 2 || ($split_msg[$split_msg_size-2] =~ "SIMERROR"))
        {
            $act_msg = $split_msg[$split_msg_size-1];
        }
        elsif($split_msg_size == 4) ## 4 fields populated
        {
            $act_msg = $split_msg[$split_msg_size-1];
        }
        else
        {
            $act_msg = $split_msg[$split_msg_size-2];
        }
        $error_bin{$act_msg} .= "$file\n";
        $error_bin_count{$act_msg}++;
    }
    elsif($msg =~ "[ERROR]")
    {
        my @split_msg = split(/:/,$msg);
        my $split_msg_size = @split_msg;
        my $act_msg = "";
        if($split_msg_size == 2 || ($split_msg[$split_msg_size-2] =~ "ERROR"))
        {
            $act_msg = $split_msg[$split_msg_size-1];
        }
        elsif($split_msg_size == 4) ## 4 fields populated
        {
            $act_msg = $split_msg[$split_msg_size-1];
        }
        else
        {
            $act_msg = $split_msg[$split_msg_size-2];
        }
        $error_bin{$act_msg} .= "$file\n";
        $error_bin_count{$act_msg}++;
    }
    elsif($msg =~ "TERMINATE")
    {
        my @split_msg = split(/:/,$msg);
        my $split_msg_size = @split_msg;
        my $act_msg = "";
        if($split_msg_size == 2 || ($split_msg[$split_msg_size-2] =~ "SIMERROR"))
        {
            $act_msg = $split_msg[$split_msg_size-1];
        }
        else
        {
            $act_msg = $split_msg[$split_msg_size-2];
        }
        $error_bin{$act_msg} .= "$file\n";
        $error_bin_count{$act_msg}++;
    }
    elsif($msg =~ "ERROR" && $msg !~ "SYSTEM ERROR")
    {
        my @split_msg = split(/:/,$msg);
        my $split_msg_size = @split_msg;
        my $act_msg = "";
        if($split_msg_size == 2 || ($split_msg[$split_msg_size-2] =~ "ERROR"))
        {
            $act_msg = $split_msg[$split_msg_size-1];
        }
        else
        {
            $act_msg = $split_msg[$split_msg_size-2];
        }
        $error_bin{$act_msg} .= "$file\n";
    }
    elsif($msg =~ "_Overflow")
    {
        $error_bin{'Overfllow_assertion'} .= "$file\n";
        $error_bin_count{'Overflow_assertion'}++;
    }
    elsif($msg =~ "_Underflow")
    {
        $error_bin{'Underfllow_assertion'} .= "$file\n";
        $error_bin_count{'Underflow_assertion'}++;
    }
    elsif($msg =~ "_assertion")
    {
        $error_bin{'Unknown_assertion'} .= "$file\n";
        $error_bin_count{'Unknown_assertion'}++;
    }
    else {
      if($msg !~ /SST2/)
      {
	      $error_bin{'Unknown'} .= "$file\n";
         $error_bin_count{'Unknown'}++;
      }
    }

}

sub status
{
    my $log_exists = 0;
    my @dirname = split(/\//,$_[0]);
    my $size = @dirname;
    my $directory = $dirname[$size-2];
    my $filename = $dirname[$size-1];
    my $safe_directory1 = "";
    my $safe_directory2 = "";
    if($size > 2)
    {
        $safe_directory1 = $dirname[$size-3];
    }
    if($size > 3)
    {
        $safe_directory2 = $dirname[$size-4];
    }
    my $hashkey = $directory.$filename;

    #print "File name is $filename\n";
    #print "hashkey = $hashkey\n";
    if($legacy == 1)
    {
      system("cp $_[0] tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename");
    }
    else
    {
      system("tail -1500 $_[0] > tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename");
    }
    $sim_ended = `grep \"SIM GOOD END\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $sim_ended += `grep PASSED tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $sim_ended_extended += `grep \"Your job looked like\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $sim_ended_extended += `grep \"\# LSBATCH: \" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $error_count = 0;
    if($legacy == 1)
    {
      $error_count = `grep ERROR tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    }
    $error_count += `grep FAILED tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $error_count += `grep \"MUX VIOLATION\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $error_count += `grep \"MUX MUTEX VIOLATION\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $error_count += `grep \"SVA_FATAL\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $error_count += `grep \"Forbidden_assertion\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $error_count += `grep \"Timeout_assertion\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $error_count += `grep \"Offending \" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $error_count += `grep \"_underflow\"  tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
#    $error_count += `grep \"_overflow\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
	if($whichbuild eq "ncv" && $ignoresimerror ne "")
	{
	}
	else
	{
    	$error_count += `egrep \"ncsim: .E\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    }
    $error_count += `grep \"TERMINATE:\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
	if($whichbuild eq "questa" && $ignoresimerror ne "")
	{
	}
	else
	{
    	$error_count += `grep \"** Error:\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
	}
    my $err = 0;
	if($whichbuild eq "ncv" && $ignoresimerror ne "")
	{
	}
	else
	{
    	$err = `egrep \"ncsim: .E\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename`;
    }
    $incomplete_run += $err;
    $incomplete_run += `grep -i \"simulation interrupted\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $incomplete_run += `grep -i \"MOVING EXPORT\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    $incomplete_run += `grep -i \"compressing files\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
#    $incomplete_run += `grep -i \"exiting on\" tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename | wc -l`;
    system("rm tmp_$safe_directory1\_$safe_directory2\_$directory\_$filename");
#    exit(0);
#        print "sim_ended = $sim_ended\n";
    $log_exists = 1;
    if($error_count != 0)
    {
#            lock($failed);
#            @error_array = `grep ERROR $_[0]/*.log`;

        my $msg = "";
#        print "Error Count\n";
        ## msg for subsystem/FC level binning
        $msg = `egrep "VERA ERROR|Fatal|HANG EXIT ERR|TIMEOUT ERR|ERROR CHECKER|ERROR RTL|Error Assert|COMPARE FAILED|ERROR: X_De|Assembler Error|ERROR: Timeout_assertion|ERROR: MUX MUTEX VIOLATION|ERROR: MUX VIOLATION|regfile|ERROR: Forbidden|BAADBEEF Failure|Simulator Error|MAX TIMEOUT ERROR|Watch Dog timer exceeds|outstanding requests in Lsu SDB|Possible leak|simulation hang|Invalid Request type|ERROR: ZeroHot_assertion|ERROR: OneHot_assertion|MAP SVA ERROR ASSERTION FAIL|ERROR CHECKER:|SVA_FATAL|SIMERROR|INTERR: INTERNAL EXCEPTION|ncsim: .E|_underflow|MAX TIMEOUT|Assertion error" -m 1 $_[0]`;
        if($msg eq "")
        {
            $msg = `egrep "ERROR:|SIMERROR | ERROR : | TERMINATE:|ERROR!" -m 1 $_[0]`;
            if($msg =~ /SYSTEM ERROR/)
            {
               $msg = "";
            }
        }
        elsif($msg eq "SYSTEM ERROR")
        {
           $msg = "";
        }
        &bin_group($msg,$_[0]);
        $fail_count{$_[0]} = $error_array[0];
#        $error_bin{$error_array[0]} .= "$_[0]\n";
#        push @{$error_bin{$error_array[0]}},$_[0];
#            print STATUSFILE "Directory $_[0] : \n";
#            print STATUSFILE "          FAILED\n";
#            print STATUSFILE @error_array;
#            $failed += 1;

    }
    elsif($log_exists == 0)
    {
#        lock($nologfile);
#        print STATUSFILE "Directory $_[0] : \n";
#        print STATUSFILE "          NOT_STARTED\n";
#        $nologfile += 1;
    }
    elsif($sim_ended != 0)
    {
#        lock($passed);
        $pass_count{$_[0]} = 1;
        print STATUSFILE "Directory $_[0] : \n";
        print STATUSFILE "          PASSED\n";
#        $passed += 1;
    }
    elsif($incomplete_run != 0)
    {
#        print "Incomplete Run\n";
        $fail_count{$_[0]} = $error_array[0];
        $error_bin{'Incomplete/Error Run'} .= "$_[0]\n";
        $error_bin_count{'Incomplete/Error Run'}++;
    }
    elsif($sim_ended_extended == 0)
    {
#        lock($running);
       if($legacy == 1)
       {
          $pass_count{$_[0]} = 1;
       }
       else
       {
          $running_count{$_[0]} = 1;
       }
#        print "Running Count increases\n";
#        print STATUSFILE "Directory $_[0] : \n";
#        print STATUSFILE "          STILL RUNNING\n";
#        $running += 1;
    }

}

sub process_files
{
    my $fork = 0;
    my $f;
    my $dir = $_[0];
#    print "Directory is $dir\n";
    $f = $_[1];
#            if(-d $f)
#            {
#                &process_files($f);
#                next;
#            }
#            else
#            {
                if($_[0] =~ /\.log/ && $_[0] !~ /tr_db/ && $_[0] !~ /tarmac/)
                {
#                    print "File is $f\n";
                    my $t = threads->new(\&status,$_[0]);
                    print "=";
                    push(@children,$t);
                }
#            }
#        &status($_);
}

sub Uniquify{
   my %list=();
   my @uniq_arr;

   $list{$_}=0 foreach (@_);

   foreach (@_){
     if(exists ($list{$_})){
       push (@uniq_arr, $_);
       delete ($list{$_});
     }
   }
   return @uniq_arr;
#   return keys %list;
}


sub call_sims
{
    my $local_run_path;
    my $local_grid;
    my $local_script_name="";
    my $local_random_number = $_[0]; ## Only argument passed
    my $local_run_name = $_[1];
    my $local_regr_dir = $_[2];
    my $localrunargs = $_[3];
    my $localsetname = $_[4];
    my $local_throttle = $_[5];
    my $local_resource = $_[6];
    my $local_build_dir = $_[7];
    my $local_build_path = $_[8];
    my $local_build_path_str = "";
    my $local_rseed = " ";
    my $local_model_name = " ";
    my $local_cpf_file_passed = "";
    my $local_upf_file_passed = "";
    my $local_rerun_failed = "";
    my $localsimulator = "";
    my $localcoverargs = "";

    if($rerun_failed == 1)
    {
       $local_rerun_failed = " -rerun_failed ";
    }
    if($separate_run_path == 1)
    {
        $local_run_path = $rundir;
    }
    else
    {
        if($local_regr_dir eq "")
        {
            $local_run_path = "$uc_model_name";
            $local_run_path .= "_REGR_$mday$hour$min$sec";
        }
        else
        {
            $local_run_path = $local_regr_dir;
        }
    }
    if($coverage == 1)
    {
       $localcoverargs = $complete_coverage_args;
    }
    if($grid == 1)
    {
        $local_grid = "-grid";
    }
    else
    {
    }

    if($cpf_passed == 1)
    {
       $local_cpf_file_passed = " -cpf=$cpf ";
    }
    if($upf_passed == 1)
    {
       $local_upf_file_passed = " -upf=$upf ";
    }

    if($script ne "")
    {
        $local_script_name = "-script=$script";
    }
    if($whichrun eq "ncv")
    {
       $localsimulator = "-ncv";
    }
    elsif($whichrun eq "questa")
    {
       $localsimulator = "-questa";
    }
    elsif($whichrun eq "vcs")
    {
       $localsimulator = "-vcs";
    }

    if($localrunargs =~ /-ncv/)
    {
       $localsimulator = "-ncv";
    }
    elsif($localrunargs =~ /-questa/)
    {
       $localsimulator = "-questa";
    }
    elsif($localrunargs =~ /-vcs/)
    {
       $localsimulator = "-vcs";
    }
    if($random_seed == 1)
    {
       $local_rseed = "-rseed ";
    }
    if($model_name ne "")
    {
       $local_model_name = "-model_name=$model_name ";
    }
    if($localrunargs =~ /-model_name/)
    {
       $local_model_name = "";
    }
    if($local_build_path eq "")
    {
       $local_build_path_str = " ";
       print "Local_build_path is null\n";
    }
    else
    {
       $local_build_path_str = "-build_path=$local_build_path";
    }
    if($local_run_name eq "")
    {
       if($run64 == 1)
       {
	 print("Command is $local_sims $localrunargs $local_model_name $ignoresimerror $local_rerun_failed $local_cpf_file_passed $localcoverargs $local_upf_file_passed -run64 -build_path=$local_build_dir -run_dir=$local_run_path $local_rseed -set=$localsetname -run_path=$runpath $local_script_name $localsimulator -tl_run -R=$local_resource -q=\"$job_q\" -maxjobs=\"$throttle\" -maxruntime=\"$max_run_time\" -job_group=\"$job_group\"\n");
         system("$local_sims $local_grid $localrunargs $local_model_name $sims_dash_args $ignoresimerror $local_rerun_failed $local_cpf_file_passed $localcoverargs$local_upf_file_passed -run64 -run_dir=$local_run_path -build_path=$local_build_dir $local_rseed -set=$localsetname -run_path=$runpath $local_script_name $localsimulator -tl_run -R=\"$local_resource\" -q=\"$job_q\" -maxjobs=\"$throttle\" -maxruntime=\"$max_run_time\" -job_group=\"$job_group\"");
       }
       else
       {
          print("Command is $local_sims $localrunargs $local_model_name $ignoresimerror $local_rerun_failed $local_cpf_file_passed $localcoverargs $local_upf_file_passed -build_path=$local_build_dir -run_dir=$local_run_path $local_rseed -set=$localsetname -run_path=$runpath $local_script_name $localsimulator -tl_run -R=$local_resource -q=\"$job_q\" -maxjobs=\"$throttle\" -maxruntime=\"$max_run_time\" -job_group=\"$job_group\"\n");
          system("$local_sims $local_grid $localrunargs $local_model_name $sims_dash_args $ignoresimerror $local_rerun_failed $local_cpf_file_passed $localcoverargs $local_upf_file_passed -build_path=$local_build_dir-run_dir=$local_run_path $local_rseed -set=$localsetname -run_path=$runpath $local_script_name $localsimulator -tl_run -R=\"$local_resource\" -q=\"$job_q\" -maxjobs=\"$throttle\" -maxruntime=\"$max_run_time\" -job_group=\"$job_group\"");
      }
    }
    else
    {
#       print "Submitting command $local_sims $localrunargs $sims_dash_args -p=$job_priority -run_dir=$local_run_path -set=$localsetname -run_path=$runpath $local_script_name -tl_run\n";
       if($run64 == 1)
       {
          print("Command is $local_sims $localrunargs $local_model_name $sims_dash_args $ignoresimerror $local_rerun_failed $local_cpf_file_passed $localcoverargs $local_upf_file_passed -run64 -build_path=$local_build_dir -run_dir=$local_run_path -run_path=$runpath $local_rseed -set=$localsetname $local_script_name $localsimulator -tl_run -R=$local_resource -q=\"$job_q\" -maxjobs=\"$throttle\" -maxruntime=\"$max_run_time\" -job_group=\"$job_group\"\n");
          system("$local_sims  $local_grid $localrunargs $local_model_name $sims_dash_args $ignoresimerror $local_rerun_failed $local_cpf_file_passed $localcoverargs $local_upf_file_passed -run64 -build_path=$local_build_dir -run_dir=$local_run_path -run_path=$runpath $local_rseed -set=$localsetname $local_script_name $localsimulator -tl_run -R=\"$local_resource\" -q=\"$job_q\" -maxjobs=\"$throttle\" -maxruntime=\"$max_run_time\" -job_group=\"$job_group\"");
       }
       else
       {
          print("Command is $local_sims $localrunargs $local_model_name $sims_dash_args $ignoresimerror $local_rerun_failed $local_cpf_file_passed $localcoverargs $local_upf_file_passed -build_path=$local_build_dir -run_dir=$local_run_path -run_path=$runpath $local_rseed -set=$localsetname $local_script_name -tl_run -R=$local_resource -q=\"$job_q\" -maxjobs=\"$throttle\" -maxruntime=\"$max_run_time\" -job_group=\"$job_group\"\n");
          system("$local_sims $local_grid $localrunargs $local_model_name $sims_dash_args $ignoresimerror $local_rerun_failed $local_cpf_file_passed $localcoverargs $local_upf_file_passed -build_path=$local_build_dir -run_dir=$local_run_path -run_path=$runpath $local_rseed -set=$localsetname $local_script_name $localsimulator -tl_run -R=\"$local_resource\" -q=\"$job_q\" -maxjobs=\"$throttle\" -maxruntime=\"$max_run_time\" -job_group=\"$job_group\"");
       }
    }

}


if($tbroot eq "")
{
   $tbroot = "$verifroot/$block";
}
my @tb_path_array = split(/\//,$tbroot);
my $array_size = @tb_path_array;

if($uc_model_name eq "")
{
    ## If fl passed, thats the model_name
    if($flist_passed == 1)
    {
        my @tmp_model = split(/\./,$flist);
        $uc_model_name = $tmp_model[0];
    }
    else
    {
        $uc_model_name = "$tb_path_array[$array_size - 1]";
    }
    $uc_model_name = "\U$uc_model_name";
}

if($uvmhome eq "")
{
   $uvmhome = "$IESHOME/tools/uvm-1.1/uvm_lib/uvm_sv";
}
if($build_dir eq "")
{
   $build_dir = getcwd();
}
if($build == 1 && $nobuild == 0)
{
   if($whichbuild eq "vcs")
   {
      if($run == 1)
      {
         $whichrun = "vcs";
      }

   }
   if($whichbuild eq "questa")
   {
      if($run == 1)
      {
         $whichrun = "questa";
      }
   }
   if($flist_passed == 0)
   {
      if($file_passed == 1)
      {
         ## A file has been passed. Create a tempfl with only this file
         open(TMPFLIST,">","$build_dir/temp.fl");
         print TMPFLIST "$file\n";
         close(TMPFLIST);
         $flist = "$build_dir/temp.fl";
      }
      else
      {
         if(open(FLIST,"<","$tbroot/vflist/tb.fl"))
         {
         }
         elsif(open(FLIST,"<","$tbroot/vflist/$tb_path_array[$array_size - 1]\.fl"))
         {
         }
         else
         {
            die("Cannot find file list to open");
         }
         system("mkdir -p $build_dir");
         open(TMPFLIST,">","$build_dir/temp.fl");
         while(<FLIST>)
         {
            chomp($_);
            if($_ =~ /\+incdir\+(.*)/ && $whichbuild eq "ncv")
            {
               print TMPFLIST "-incdir $1\n"
            }
            elsif($_ =~ /-incdir (.*)/ && ($whichbuild eq "vcs" or $whichbuild eq "questa"))
            {
               print TMPFLIST "\+incdir\+$1\n";
            }
            elsif($_ =~ /\+define\+(.*)/ && $whichbuild eq "ncv")
            {
               print TMPFLIST "-define $1\n"
            }
            elsif($_ =~ /-define (.*)/ && ($whichbuild eq "vcs" or $whichbuild eq "questa"))
            {
               print TMPFLIST "\+define\+$1\n";
            }
            else
            {
               print TMPFLIST "$_\n";
            }
         }
         close(FLIST);
         close(TMPFLIST);
         $flist = "$build_dir/temp.fl";
      }
   }
   else
   {
      # file list has been passed
      if(!-e $flist)
      {
         print "Did not find $flist in current directory. Looking under $tbroot/vflist\n";
         if(!-e "$tbroot/vflist/$flist")
         {
            die("file list $flist not found either in current directory or $tbroot/vflist\n");
         }
         else
         {
            $flist = "$tbroot/vflist/$flist";
         }
      }
   }
   if($builddebug  == 1)
   {
       $vcs_build .= " -debug_all";
       $vcs_build64 .= " -debug_all";
       $ncv_build .= "-linedebug ";
       $ncv_build64 .= "-linedebug ";
   }

   if($build64 == 1)
   {
      if($whichbuild eq "ncv")
      {
         if($clean == 1)
         {
            system("rm -rf $build_dir/INCA64_$model_name");
            system("rm -rf $build_dir/$model_name\_ncv_comp64.log");
         }
         if($coverage == 1)
         {
            if($coverage_args eq "")
            {
               $buildcmd .= "$ncv_build64 $irunOpts -coverage all $defines -l $model_name\_ncv_comp64.log -f $flist -nclibdirname INCA64_$model_name ";
            }
            else
            {
               $buildcmd .= "$ncv_build64 $irunOpts $coverage_args $defines -l $model_name\_ncv_comp64.log -f $flist -nclibdirname INCA64_$model_name ";
            }
         }
         else
         {
            $buildcmd .= "$ncv_build64 $irunOpts $coverage_args $defines -l $model_name\_ncv_comp64.log -f $flist -nclibdirname INCA64_$model_name ";
         }
      }
      elsif($whichbuild eq "vcs")
      {
         if($clean == 1)
         {
            system("rm -rf $build_dir/simv_$model_name\.*");
            system("rm -rf $build_dir/csrc");
            system("rm -rf $build_dir/$model_name\_vcs_comp.log");
         }
         $buildcmd .= "$vcs_build64 $defines +v2k +memcbk +nowarnTFMPC -assert quiet -Mupdate=1 -l $model_name\_vcs_comp.log -f $flist -o simv_$model_name ";
      }
      else
      {
         if($clean == 1)
         {
            if(-d questa64)
            {
               system("rm -rf questa64");
            }
            system("rm -rf $build_dir/questa64");
            print "Deleting $build_dir/$model_name\_questa_comp.log\n";
            system("rm -rf $build_dir/$model_name\_questa_comp.log");
            system("rm -rf $build_dir/$model_name");
         }
         #$buildcmd .= "$questa_build64 -suppress 2181,2619,2263,2240,2244,2257,2239,2727,8386 -work $model_name $questaOpts $incr $defines -l $model_name\_questa_comp.log -writetoplevels toplevels -f $flist ";
         $buildcmd .= "$questa_build64 -work $model_name $questaOpts $incr $defines -l $model_name\_questa_comp.log -writetoplevels toplevels -f $flist ";
      }
   }
   else
   {
      if($whichbuild eq "ncv")
      {
         if($clean == 1)
         {
            system("rm -rf $build_dir/INCA_$model_name");
            system("rm -rf $build_dir/$model_name\_ncv_comp64.log");
         }
         if($coverage == 1)
         {
            if($coverage_args eq "")
            {
               $buildcmd .= "$ncv_build $irunOpts -coverage all $defines -l $model_name\_ncv_comp.log -f $flist -nclibdirname INCA_$model_name ";
            }
            else
            {
               $buildcmd .= "$ncv_build $irunOpts $coverage_args $defines -l $model_name\_ncv_comp.log -f $flist -nclibdirname INCA_$model_name ";
            }
         }
         else
         {
            $buildcmd .= "$ncv_build $irunOpts $coverage_args $defines -l $model_name\_ncv_comp.log -f $flist -nclibdirname INCA_$model_name ";
         }
      }
      elsif($whichbuild eq "vcs")
      {
         if($clean == 1)
         {
            system("rm -rf $build_dir/simv_$model_name\.*");
            system("rm -rf $build_dir/csrc");
            system("rm -rf $build_dir/$model_name\_vcs_comp.log");
         }
         $buildcmd .= "$vcs_build $defines +v2k +memcbk +nowarnTFMPC -assert quiet -Mupdate=1 -l $model_name\_vcs_comp.log -f $flist -o simv_$model_name ";
      }
      else
      {
         if($clean == 1)
         {
            if(-d questa)
            {
               system("rm -rf questa");
            }
            system("rm -rf $build_dir/questa");
            system("rm -rf $build_dir/work");
            system("rm -rf $build_dir/$model_name\_questa_comp.log");
         }
         #$buildcmd .= "$questa_build32 -suppress 2181,2619,2263,2240,2244,2257,2239,2727,8386 -work $model_name $questaOpts $incr $defines -l $model_name\_questa_comp.log -writetoplevels toplevels -f $flist ";
         $buildcmd .= "$questa_build32 -work $model_name $questaOpts $incr $defines -l $model_name\_questa_comp.log -writetoplevels toplevels -f $flist ";
      }
   }
   system("mkdir -p $build_dir");
   chdir($build_dir);
   if($whichbuild eq "questa")
   {

      if(-e "toplevels")
      {
         if($clean == 1)
         {
            system("rm -rf toplevels");
         }
      }
      if($model_name eq "libs")
      {
         $model_name = "work";
      }
      system("vlib $model_name");
   }
   print "Build command is $buildcmd\n";
#   exit(0);
   system($buildcmd);
   if($whichbuild eq "questa")
   {
      ## Check to see if there were any compilation errors
      open(QUESTACOMP,"<","$build_dir/$model_name\_questa_comp.log");
      while(<QUESTACOMP>)
      {
         if($_ =~ /Error:/)
         {
            print("\n\n");
            die("Questa Compilation Failed with $_\n");
            print("\n\n");
         }
      }
      close(QUESTACOMP);
      if($coverage == 1)
      {
         if($coverage_args ne "")
         {
            #system("vopt -suppress 2250,8637 -debug +designfile+$model_name\.bin $incr -work $build_dir/$model_name $questa_vopt_args +cover=$coverage_args -f toplevels $questa_upf -o $model_name\_top -l vopt.log");
            #system("vopt -debug +designfile+$model_name\.bin $incr -work $build_dir/$model_name $questa_vopt_args +cover=$coverage_args -f toplevels $questa_upf -o $model_name\_top -l vopt.log");
            system("vopt -debug +designfile+$model_name\.bin $incr -work $build_dir/$model_name $questa_vopt_args -f toplevels $questa_upf -o $model_name\_top -l vopt.log");
            #system("vsim -suppress 3829,3881,3819 $dumpopts $extra_questaOpts $questa_elab_opts $model_name\_top -lib $build_dir/$model_name -elab $model_name\_elab -l $model_name\_elab.log ");
            system("vsim $dumpopts $extra_questaOpts $questa_elab_opts $model_name\_top -lib $build_dir/$model_name -elab $model_name\_elab -l $model_name\_elab.log -coverage -suppress 7041");
         }
         else
         {
            #system("vopt -suppress 2250,8637 -debug +designfile+$model_name\.bin +cover $incr -work $build_dir/$model_name $questa_vopt_args -f toplevels $questa_upf -o $model_name\_top -l vopt.log");
            #system("vopt -debug +designfile+$model_name\.bin $incr -work $build_dir/$model_name $questa_vopt_args -f toplevels $questa_upf -o $model_name\_top -l vopt.log");
            system("vopt -debug +designfile+$model_name\.bin  $incr -work $build_dir/$model_name $questa_vopt_args -f toplevels $questa_upf -o $model_name\_top -l vopt.log"); 
            #system("vsim -suppress 3829,3881,3819 $dumpopts $extra_questaOpts $questa_elab_opts $model_name\_top -lib $build_dir/$model_name -elab $model_name\_elab -l $model_name\_elab.log ");
            system("vsim $dumpopts $extra_questaOpts $questa_elab_opts $model_name\_top -lib $build_dir/$model_name -elab $model_name\_elab -l $model_name\_elab.log -coverage -suppress 7041");
         }
      }
      else
      {
         #system("vopt -suppress 2250,8637 -debug +designfile+$model_name\.bin $incr -work $build_dir/$model_name $questa_vopt_args -f toplevels $questa_upf -o $model_name\_top -l vopt.log");
         system("vopt -debug +designfile+$model_name\.bin $incr -work $build_dir/$model_name $questa_vopt_args -f toplevels $questa_upf -o $model_name\_top -l vopt.log");
         #system("vsim -suppress 3829,3881,3819 $dumpopts $extra_questaOpts $questa_elab_opts $model_name\_top -lib $build_dir/$model_name -elab $model_name\_elab -l $model_name\_elab.log ");
         system("vsim $dumpopts $extra_questaOpts $questa_elab_opts $model_name\_top -lib $build_dir/$model_name -elab $model_name\_elab -l $model_name\_elab.log -suppress 7041");
      }
      open(QUESTAOPT,"<","vopt.log");
      while(<QUESTAOPT>)
      {
         if($_ =~ /Error:/)
         {
            print("\n\n");
            die("Questa Optimization failed with $_\n");
            print("\n\n");
         }
      }
      close(QUESTAOPT);
      open(QUESTAELAB,"<","$model_name\_elab.log");
      while(<QUESTAELAB>)
      {
         if($_ =~ /Error:/)
         {
            print("\n\n");
            die("Questa Elaboration failed with $_\n");
            print("\n\n");
         }
      }
      close(QUESTAELAB);
   }
   system("rm temp.fl");
}

## Check if the build happened properly
if($whichbuild eq "ncv" && $nobuild == 0)
{
   if($build64 == 1)
   {
      open(NCVBUILD,"<","$build_dir/$model_name\_ncv_comp64.log");
      while(<NCVBUILD>)
      {
         if($_ =~ /\*E/)
         {
            die("\n\nCompilation failed with first Error $_.\n\n");
         }
      }
      close(NCVBUILD);
   }
   else
   {
      open(NCVBUILD,"<","$build_dir/$model_name\_ncv_comp.log");
      while(<NCVBUILD>)
      {
         if($_ =~ /\*E/)
         {
            die("\n\nCompilation failed with first Error $_.\n\n");
         }
      }
      close(NCVBUILD);
   }

}
if($run == 1)
{
   my $perlsection_begin = 0;
   my $start_tl_parse = 0;
   my $multiline_comment = 0;
## runs by default
   if($testlist_passed == 1)
   {
       if($job_group eq "") 
       {
         $job_group = "/$user/";
         $job_group .= "__REGR_$mday$hour$min$sec";
       }
       ## What if the testlist is comma separated
       print "Test List Passed is $testlist\n";
       @regr_array = split(/,/,$regr);
       my $regr_array_size = @regr_array;
       if($regr_array_size == 0)
       {
           $start_tl_parse = 1; ## Parse everything in the testlist
           if(open(TESTLIST,"<","$testlist"))
           {
           }
           elsif(open(TESTLIST,"<","$tbroot/tests/$testlist"))
           {

           }
           else
           {
               die("Could not open Test List File $testlist either in the local area or \$TB_ROOT\n");
           }

           if($separate_run_path == 1)
           {
              $regr_dir = "$rundir";
               if(-d "$runpath/$regr_dir")
               {
                   system("rm -rf $runpath/$regr_dir");
               }
           }
           else
           {
              $regr_dir = "$uc_model_name\_REGR\_$mday$hour$min$sec";
               if(-d "$runpath/$regr_dir")
               {
                   system("\\rm -rf $runpath/$regr_dir");
               }
           }
           while(<TESTLIST>)
           {
               chomp($_);
               ~s/^\s+//g;
               if($_ =~ /^\s*#/)
               {
                   next;
               }
               elsif($_ =~ /^\s*\S+_BEGIN/ && $_ !~ /PERL/)
               {
                   next;
               }
               elsif($_ =~ /^\s*\S+_END/ && $_ !~ /PERL/)
               {
                   next;
               }
               elsif($_ eq "")
               {
                   next;
               }
               elsif($_ =~ /^\s*#/)
               {
                   next;
               }
               elsif($_ =~ /^\s*\/\//)
               {
                   next;
               }
               elsif($_ =~ /$\s*#/) ## Comment at end of line
               {
                   print "Old line is $_\n";
                   $_ =~ s/#.*//;
                   print "New is $_\n";
               }
               elsif($_ =~ /$\s*\/\//)
               {
                   $_ =~ s/\/\/.*//;
               }
               elsif($_ =~ /^\s*\/\*.*/)
               {
                   $multiline_comment = 1;
                   next;
               }
               elsif($_ =~ /^\s*.*\*\//)
               {
                   $multiline_comment = 0;
                   next;
               }
               if($multiline_comment == 1)
               {
                   next;
               }
               if($start_tl_parse == 1) ## What if there is perl code in here
               {
                   $runargs .= $simulator_run_args;
                   if($whichrun eq "ncv")
                   {
                      $runargs .= " -irun_r_opts=\"$extra_irunOpts\" ";
                   }
                   elsif($whichrun eq "questa")
                   {
                      $runargs .= " -questa_r_opts=\"$extra_questaOpts\" ";
                   }

                   if($_ =~ /PERL_BEGIN/)
                   {
                       $perlsection_begin = 1;
                       open(PERLCODE,">","perlfile.pl");
                       print PERLCODE "#!/usr/bin/perl\n";
                       print PERLCODE "use strict;\n\n";
                       print PERLCODE "my \$num_tests=1;\n";
                       print PERLCODE "my \$var1=0;\n";
                       print PERLCODE "my \$var1_passed=0;\n";
                       print PERLCODE "my \$var2=0;\n";
                       print PERLCODE "my \$var2_passed=0;\n";
                       print PERLCODE "my \$var3=0;\n";
                       print PERLCODE "my \$var3_passed=0;\n";
                       print PERLCODE "my \$var4=0;\n";
                       print PERLCODE "my \$var4_passed=0;\n";
                       print PERLCODE "my \$var5=0;\n";
                       print PERLCODE "my \$var5_passed=0;\n";
                       print PERLCODE "foreach my \$args \(\@ARGV\)\n";
                       print PERLCODE "\{\n";
                       print PERLCODE "    if\(\$args =~ \/-num_tests=\(.*\)\/\)\n";
                       print PERLCODE "    \{\n";
                       print PERLCODE "        \$num_tests = \$1;\n";
                       print PERLCODE "    \}\n";
                       print PERLCODE "    elsif\(\$args =~ \/-var1=\(.*\)\/\)\n";
                       print PERLCODE "    \{\n";
                       print PERLCODE "        \$var1 = \$1;\n";
                       print PERLCODE "        \$var1_passed = 1;\n";
                       print PERLCODE "    \}\n";
                       print PERLCODE "    elsif\(\$args =~ \/-var2=\(.*\)\/\)\n";
                       print PERLCODE "    \{\n";
                       print PERLCODE "        \$var2 = \$1;\n";
                       print PERLCODE "        \$var2_passed = 1;\n";
                       print PERLCODE "    \}\n";
                       print PERLCODE "    elsif\(\$args =~ \/-var3=\(.*\)\/\)\n";
                       print PERLCODE "    \{\n";
                       print PERLCODE "        \$var3 = \$1;\n";
                       print PERLCODE "        \$var3_passed = 1;\n";
                       print PERLCODE "    \}\n";
                       print PERLCODE "    elsif\(\$args =~ \/-var4=\(.*\)\/\)\n";
                       print PERLCODE "    \{\n";
                       print PERLCODE "        \$var4 = \$1;\n";
                       print PERLCODE "        \$var4_passed = 1;\n";
                       print PERLCODE "    \}\n";
                       print PERLCODE "    elsif\(\$args =~ \/-var5=\(.*\)\/\)\n";
                       print PERLCODE "    \{\n";
                       print PERLCODE "        \$var5 = \$1;\n";
                       print PERLCODE "        \$var5_passed = 1;\n";
                       print PERLCODE "    \}\n";
                       print PERLCODE "\}\n\n";

                       next;
                   }
                   if($_ =~ /PERL_END/)
                   {
                       $perlsection_begin = 0;
                       close(PERLCODE);
                       chmod(0755,"perlfile.pl");
                       system("perlfile.pl $num_tests $var1 $var2 $var3 $var4 $var5 > perltest");
                       open(PERLTEST,"<","perltest");
                       while(<PERLTEST>)
                       {
                           chomp($_);

                           $runargs .= " $_ ";
#                           print "runargs read $runargs\n";
                           $random_number = int(rand(10000000));
                           while(-e "REGR$random_number")
                           {
                               $random_number = int(rand(10000000));
                           }
                           if($runargs =~ /-test=(.*)/ && $runargs !~ /-N/)
                           {
                               if($test_name_used{$1} == 1)
                               {
                                   open(TMP,">","tmp_mail");
                                   print TMP "WARNING : Test Directory $1 already used in the testlist. Previous run will be overwritten\n";
                                   close(TMP);
                                   foreach my $receivers (@mail_receiver)
                                   {
                                       system("mail $receivers -s \"sims runtime error\" < tmp_mail");
                                   }
                                   system("rm tmp_mail");
                               }
                               $test_name_used{$1} = 1;
                               if($runargs =~ /string2warning=\"(.*)\" /)
                               {
                                   my @tmpstrings = split(/\+/,$1);
                                   my @joinstrings;
                                   my $tmpmodstrings;
                                   foreach my $tmp (@tmpstrings)
                                   {
                                       $tmp =~ s/\"/\\"/g;
                                       $tmp =~ s/ /\\ /g;
                                       push(@joinstrings,$tmp);
                                   }
                                   $tmpmodstrings = join("+",@joinstrings);
                                   $runargs =~ s/string2warning=\"(.*)\"/string2warning=\\\"$tmpmodstrings\\\"/;
                               }
                               if($runargs =~ /block2warning=\"(.*)\" /)
                               {
                                   my @tmpblocks = split(/\,/,$1);
                                   my @joinblocks;
                                   my $tmpmodblocks;
                                   foreach my $tmp (@tmpblocks)
                                   {
                                       $tmp =~ s/\"/\\"/g;
                                       $tmp =~ s/ /\\ /g;
                                       push(@joinblocks,$tmp);
                                   }
                                   $tmpmodblocks = join("+",@joinblocks);
                                   $runargs =~ s/block2warning=\"(.*)\"/block2warning=\\\"$tmpmodblocks\\\"/;
                               }


                               $setname = "$uc_model_name\_REGR\_$mday$hour$min$sec";
                               print "Will be calling with build_path=$build_path\n";
                               &call_sims($random_number,$1,$regr_dir,$runargs,"$uc_model_name\_REGR\_$mday$hour$min$sec",$throttle,$resource,$build_dir,$build_path);
                           }
                           else
                           {
                               if($runargs =~ /string2warning=\"(.*)\" /)
                               {
                                   my @tmpstrings = split(/\+/,$1);
                                   my @joinstrings;
                                   my $tmpmodstrings;
                                   foreach my $tmp (@tmpstrings)
                                   {
                                       $tmp =~ s/\"/\\"/g;
                                       $tmp =~ s/ /\\ /g;
                                       push(@joinstrings,$tmp);
                                   }
                                   $tmpmodstrings = join("+",@joinstrings);
                                   $runargs =~ s/string2warning=\"(.*)\"/string2warning=\\\"$tmpmodstrings\\\"/;
                               }

                               if($runargs =~ /block2warning=\"(.*)\" /)
                               {
                                   my @tmpblocks = split(/\,/,$1);
                                   my @joinblocks;
                                   my $tmpmodblocks;
                                   foreach my $tmp (@tmpblocks)
                                   {
                                       $tmp =~ s/\"/\\"/g;
                                       $tmp =~ s/ /\\ /g;
                                       push(@joinblocks,$tmp);
                                   }
                                   $tmpmodblocks = join("+",@joinblocks);
                                   $runargs =~ s/block2warning=\"(.*)\"/block2warning=\\\"$tmpmodblocks\\\"/;
                               }


                               $setname = "$uc_model_name\_REGR\_$mday$hour$min$sec";
                               print "Will be calling with build_path=$build_path\n";
                               &call_sims($random_number,"",$regr_dir,$runargs,"$uc_model_name\_REGR\_$mday$hour$min$sec",$throttle,$resource,$build_dir,$build_path);
                           }
                           $runargs = "";
                           $runargs .= $simulator_run_args;
                           $runargs .= " -irun_r_opts=\"$extra_irunOpts\" ";
                       }
                       close(PERLTEST);
                       $runargs = "";
                       next;
                   }
                   if($perlsection_begin == 1)
                   {
                       print PERLCODE "$_\n";
                   }
                   else
                   {
                       $runargs .= " $_ ";
#                       print "runargs read $runargs\n";
                       $random_number = int(rand(10000000));
                       while(-e "REGR$random_number")
                       {
                           $random_number = int(rand(10000000));
                       }
                       if($runargs =~ /-test=(.*)/ && $runargs !~ /-N/)
                       {
                           if($test_name_used{$1} == 1)
                           {
                               open(TMP,">","tmp_mail");
                               print TMP "WARNING : Test Directory $1 already used in the testlist. Previous run will be overwritten\n";
                               close(TMP);
                               foreach my $receivers (@mail_receiver)
                               {
                                   system("mail $receivers -s \"sims runtime error\" < tmp_mail");
                               }
                               system("rm tmp_mail");
                           }
                           $test_name_used{$1} = 1;

                           $setname = "$uc_model_name\_REGR\_$mday$hour$min$sec";
                           print "Will be calling with build_path=$build_path\n";
                           &call_sims($random_number,$1,$regr_dir,$runargs,"$uc_model_name\_REGR\_$mday$hour$min$sec",$throttle,$resource,$build_dir,$build_path);
                       }
                       else
                       {
                          $setname = "$uc_model_name\_REGR\_$mday$hour$min$sec";
                          print "Will be calling with build_path=$build_path\n";
                          &call_sims($random_number,"",$regr_dir,$runargs,"$uc_model_name\_REGR\_$mday$hour$min$sec",$throttle,$resource,$build_dir,$build_path);
                       }

                   }
                   $runargs = "";
               }
           }
           close(TESTLIST);
           sleep(5);
           if($wait == 1 && $nomail == 1)
           {
              print("Will be waiting on $setname\n");
              sleep(5);
              my $myjobs = (`bjobs -w | grep "PEND" | grep \"$setname\" |wc -l` + `bjobs -w | grep "RUN" | grep \"$setname\" |wc -l`);
              my $totaljobs = $myjobs;
              my $pendingjobs;
              my $runningjobs;
              my $failingjobs;
	      while ($myjobs >0) {
                sleep(10);
                $myjobs = (`bjobs -w | grep "PEND" | grep \"$setname\" |wc -l` + `bjobs -w | grep "RUN" | grep \"$setname\" |wc -l`);
                #print "Running_Jobs $myjobs\n";
	      }	
           }
           if($post_script ne "")
           {
              system($post_script);
           }
           if($nomail == 0)
           {

              print("$local_sims -status=$runpath/$regr_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string\n");
              system("$local_sims -status=$runpath/$regr_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string");

              if($runpath =~ /scratch/)
              {
              }
              else
              {
                 if($nocopy == 1)
                 {
                    $copy_runpath = "$runpath";
                 }
                 else
                 {
                    print("Now moving $runpath/$uc_model_name\_REGR\_$mday$hour$min$sec to $copy_runpath\n");
                    system("mv $runpath/$regr_dir $copy_runpath");
                 }
              }

               print("Log file(s) located under $copy_runpath/$uc_model_name\_REGR\_$mday$hour$min$sec\n\n");
               print("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string\n");
               system("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string");
           }
           else
           {
              if($wait == 1)
              {
                 if($runpath =~ /scratch/)
                 {
                 }
                 else
                 {
                    if($nocopy == 1)
                    {
                       $copy_runpath = "$runpath";
                    }
                    else
                    {
                       print("Now moving $runpath/$regr_dir to $copy_runpath\n");
#               if(-d "$copy_runpath/$regr_dir")
#               {
#                  system("rm -rf $copy_runpath/$regr_dir");
#               }
                       system("mv $runpath/$regr_dir $copy_runpath");
                    }
                 }
                 print("Log file(s) located under $copy_runpath/$regr_dir\n\n");
                 if($merge_coverage)
                 {
                   print("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -cov_merge=$merge_cov_tool -old_cov_rpt=$ena_old_cov_merge -norun $rerun_failed_string $legacy_string\n");
                   system("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -cov_merge=$merge_cov_tool -old_cov_rpt=$ena_old_cov_merge -norun $rerun_failed_string $legacy_string");
                 }
                 else
                 {
                   print("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -norun $rerun_failed_string $legacy_string\n");
                   system("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -norun $rerun_failed_string $legacy_string");
                 }
              }
           }
       }
       else
       {
           foreach my $regr_list (@regr_array)
           {
               if(open(TESTLIST,"<","$testlist"))
               {
               }
               elsif(open(TESTLIST,"<","$tbroot/tests/$testlist"))
               {

               }
               else
               {
                   die("Could not open Test List File $testlist either in the local area or \$TB_ROOT\n");
               }

               if($separate_run_path == 1)
               {
                   $regr_dir = "$rundir";
                   if(-d "$runpath/$regr_dir")
                   {
                       system("rm -rf $runpath/$regr_dir");
                   }
               }
               else
               {
                   $regr_dir = "$uc_model_name\_$regr_list\_REGR\_$mday$hour$min$sec";
                   if(-d "$runpath/$regr_dir")
                   {
                       system("rm -rf $runpath/$regr_dir");
                   }
               }

               while(<TESTLIST>)
               {
                   chomp($_);
                   ~s/^\s+//g;
                   if($_ =~ /$regr_list\_BEGIN/)
                   {
                       $start_tl_parse = 1;
                       next;
                   }
                   elsif($_ =~ /$regr_list\_END/)
                   {
                       $start_tl_parse = 0;
                       last;
                   }
                   elsif($_ =~ /^\s*#/)
                   {
                       next;
                   }
                   elsif($_ eq "")
                   {
                       next;
                   }
                   elsif($_ =~ /^\s*#/)
                   {
                       next;
                   }
                   elsif($_ =~ /^\s*\/\//)
                   {
                       next;
                   }
                   elsif($_ =~ /$\s*#/) ## Comment at end of line
                   {
                       print "Old line is $_\n";
                       $_ =~ s/#.*//;
                       print "New is $_\n";
                   }
                   elsif($_ =~ /$\s*\/\//)
                   {
                       $_ =~ s/\/\/.*//;
                   }
                   elsif($_ =~ /^\s*\/\*.*/)
                   {
                       $multiline_comment = 1;
                       next;
                   }
                   elsif($_ =~ /^\s*.*\*\//)
                   {
                       $multiline_comment = 0;
                       next;
                   }
                   if($multiline_comment == 1)
                   {
                       next;
                   }
                   if($start_tl_parse == 1) ## What if there is perl code in here
                   {
                       $runargs .= $simulator_run_args;
                       $runargs .= " -irun_r_opts=\"$extra_irunOpts\" ";
                       if($_ =~ /PERL_BEGIN/)
                       {
                           $perlsection_begin = 1;
                           open(PERLCODE,">","perlfile.pl");
                           print PERLCODE "#!/usr/bin/perl\n";
                           print PERLCODE "use strict;\n\n";
                           print PERLCODE "my \$num_tests=1;\n";
                           print PERLCODE "my \$var1=0;\n";
                           print PERLCODE "my \$var1_passed=0;\n";
                           print PERLCODE "my \$var2=0;\n";
                           print PERLCODE "my \$var2_passed=0;\n";
                           print PERLCODE "my \$var3=0;\n";
                           print PERLCODE "my \$var3_passed=0;\n";
                           print PERLCODE "my \$var4=0;\n";
                           print PERLCODE "my \$var4_passed=0;\n";
                           print PERLCODE "my \$var5=0;\n";
                           print PERLCODE "my \$var5_passed=0;\n";
                           print PERLCODE "foreach my \$args \(\@ARGV\)\n";
                           print PERLCODE "\{\n";
                           print PERLCODE "    if\(\$args =~ \/-num_tests=\(.*\)\/\)\n";
                           print PERLCODE "    \{\n";
                           print PERLCODE "        \$num_tests = \$1;\n";
                           print PERLCODE "    \}\n";
                           print PERLCODE "    elsif\(\$args =~ \/-var1=\(.*\)\/\)\n";
                           print PERLCODE "    \{\n";
                           print PERLCODE "        \$var1 = \$1;\n";
                           print PERLCODE "        \$var1_passed = 1;\n";
                           print PERLCODE "    \}\n";
                           print PERLCODE "    elsif\(\$args =~ \/-var2=\(.*\)\/\)\n";
                           print PERLCODE "    \{\n";
                           print PERLCODE "        \$var2 = \$1;\n";
                           print PERLCODE "        \$var2_passed = 1;\n";
                           print PERLCODE "    \}\n";
                           print PERLCODE "    elsif\(\$args =~ \/-var3=\(.*\)\/\)\n";
                           print PERLCODE "    \{\n";
                           print PERLCODE "        \$var3 = \$1;\n";
                           print PERLCODE "        \$var3_passed = 1;\n";
                           print PERLCODE "    \}\n";
                           print PERLCODE "    elsif\(\$args =~ \/-var4=\(.*\)\/\)\n";
                           print PERLCODE "    \{\n";
                           print PERLCODE "        \$var4 = \$1;\n";
                           print PERLCODE "        \$var4_passed = 1;\n";
                           print PERLCODE "    \}\n";
                           print PERLCODE "    elsif\(\$args =~ \/-var5=\(.*\)\/\)\n";
                           print PERLCODE "    \{\n";
                           print PERLCODE "        \$var5 = \$1;\n";
                           print PERLCODE "        \$var5_passed = 1;\n";
                           print PERLCODE "    \}\n";
                           print PERLCODE "\}\n\n";
                           next;
                       }
                       if($_ =~ /PERL_END/)
                       {
                           $perlsection_begin = 0;
                           close(PERLCODE);
                           chmod(0755,"perlfile.pl");
                           system("perlfile.pl $num_tests $var1 $var2 $var3 $var4 $var5 > perltest");
                           open(PERLTEST,"<","perltest");
                           while(<PERLTEST>)
                           {
                               chomp($_);

                               $runargs .= " $_ ";
#                                print "runargs read $runargs\n";
                               $random_number = int(rand(10000000));
                               while(-e "$regr_list\_REGR$random_number")
                               {
                                   $random_number = int(rand(10000000));
                               }
                                print "TESTNAME = $run_name\n";
                               if($runargs =~ /-test=(.*)/ && $runargs !~ /-N/)
                               {
                                   if($test_name_used{$1} == 1)
                                   {
                                       open(TMP,">","tmp_mail");
                                       print TMP "WARNING : Test Directory $1 already used in the testlist. Previous run will be overwritten\n";
                                       close(TMP);
                                       foreach my $receivers (@mail_receiver)
                                       {
                                           system("mail $receivers -s \"sims runtime error\" < tmp_mail");
                                       }
                                       system("rm tmp_mail");
                                   }
                                   $test_name_used{$1} = 1;
                                   if($runargs =~ /string2warning=\"(.*)\" /)
                                   {
                                       my @tmpstrings = split(/\+/,$1);
                                       my @joinstrings;
                                       my $tmpmodstrings;
                                       foreach my $tmp (@tmpstrings)
                                       {
                                           $tmp =~ s/\"/\\"/g;
                                           $tmp =~ s/ /\\ /g;
                                           push(@joinstrings,$tmp);
                                       }
                                       $tmpmodstrings = join("+",@joinstrings);
                                       $runargs =~ s/string2warning=\"(.*)\"/string2warning=\\\"$tmpmodstrings\\\"/;
                                   }

                                   if($runargs =~ /block2warning=\"(.*)\" /)
                                   {
                                       my @tmpblocks = split(/\,/,$1);
                                       my @joinblocks;
                                       my $tmpmodblocks;
                                       foreach my $tmp (@tmpblocks)
                                       {
                                           $tmp =~ s/\"/\\"/g;
                                           $tmp =~ s/ /\\ /g;
                                           push(@joinblocks,$tmp);
                                       }
                                       $tmpmodblocks = join("+",@joinblocks);
                                       $runargs =~ s/block2warning=\"(.*)\"/block2warning=\\\"$tmpmodblocks\\\"/;
                                   }


                                   $setname = "$uc_model_name\_$regr_list\_REGR\_$mday$hour$min$sec";
                                   print "Will be calling with build_path=$build_path\n";
                                   &call_sims($random_number,$1,$regr_dir,$runargs,"$uc_model_name\_REGR\_$mday$hour$min$sec",$throttle,$resource,$build_dir,$build_path);
                               }
                               else
                               {
                                   if($runargs =~ /string2warning=\"(.*)\" /)
                                   {
                                       my @tmpstrings = split(/\+/,$1);
                                       my @joinstrings;
                                       my $tmpmodstrings;
                                       foreach my $tmp (@tmpstrings)
                                       {
                                           $tmp =~ s/\"/\\"/g;
                                           $tmp =~ s/ /\\ /g;
                                           push(@joinstrings,$tmp);
                                       }
                                       $tmpmodstrings = join("+",@joinstrings);
                                       $runargs =~ s/string2warning=\"(.*)\"/string2warning=\\\"$tmpmodstrings\\\"/;
                                   }

                                   if($runargs =~ /block2warning=\"(.*)\" /)
                                   {
                                       my @tmpblocks = split(/\,/,$1);
                                       my @joinblocks;
                                       my $tmpmodblocks;
                                       foreach my $tmp (@tmpblocks)
                                       {
                                           $tmp =~ s/\"/\\"/g;
                                           $tmp =~ s/ /\\ /g;
                                           push(@joinblocks,$tmp);
                                       }
                                       $tmpmodblocks = join("+",@joinblocks);
                                       $runargs =~ s/block2warning=\"(.*)\"/block2warning=\\\"$tmpmodblocks\\\"/;
                                   }


                                   $setname = "$uc_model_name\_$regr_list\_REGR\_$mday$hour$min$sec";
                                   print "Will be calling with build_path=$build_path\n";
                                   &call_sims($random_number,"",$regr_dir,$runargs,"$uc_model_name\_REGR\_$mday$hour$min$sec",$throttle,$resource,$build_dir,$build_path);
                               }

                               $runargs = "";
                               $runargs .= $simulator_run_args;
                               $runargs .= " -irun_r_opts=\"$extra_irunOpts\" ";
                           }
                           close(PERLTEST);
                           $runargs = "";
                           next;
                       }
                       if($perlsection_begin == 1)
                       {
                           print PERLCODE "$_\n";
                       }
                       else
                       {
                           $runargs .= " $_ ";
#                            print "runargs read $runargs\n";
                           $random_number = int(rand(10000000));
                           while(-e "$regr_list\_REGR$random_number")
                           {
                               $random_number = int(rand(10000000));
                           }
                           if($runargs =~ /-test=(.*)/ && $runargs !~ /-N/)
                           {
                               if($test_name_used{$1} == 1)
                               {
                                   open(TMP,">","tmp_mail");
                                   print TMP "WARNING : Test Directory $1 already used in the testlist. Previous run will be overwritten\n";
                                   close(TMP);
                                   foreach my $receivers (@mail_receiver)
                                   {
                                       system("mail $receivers -s \"sims runtime error\" < tmp_mail");
                                   }
                                   system("rm tmp_mail");
                               }
                               $test_name_used{$1} = 1;

                               $setname = "$uc_model_name\_$regr_list\_REGR\_$mday$hour$min$sec";
                               print "Will be calling with build_path=$build_path\n";
                               &call_sims($random_number,$1,$regr_dir,$runargs,"$uc_model_name\_REGR\_$mday$hour$min$sec",$throttle,$resource,$build_dir,$build_path);
                           }
                           else
                           {
                               $setname = "$uc_model_name\_$regr_list\_REGR\_$mday$hour$min$sec";
                               print "Will be calling with build_path=$build_path\n";
                               &call_sims($random_number,"",$regr_dir,$runargs,"$uc_model_name\_REGR\_$mday$hour$min$sec",$throttle,$resource,$build_dir,$build_path);
                           }

                       }
                       $runargs = "";
                   }
               }
               close(TESTLIST);
               sleep(2);
                if($wait == 1 && $nomail == 1)
                {
                   print("Will be waiting on $setname\n");
           sleep(5);
         	   my  $myjobs = (`bjobs -w | grep "PEND" | grep \"$setname\" |wc -l` + `bjobs -w | grep "RUN" | grep \"$setname\" |wc -l`);
                   my $totaljobs = $myjobs;
                   my $pendingjobs;
                   my $runningjobs;
                   my $failingjobs;
	           while ($myjobs >0) {
                      sleep(10);
         	      $myjobs = (`bjobs -w | grep "PEND" | grep \"$setname\" |wc -l` + `bjobs -w | grep "RUN" | grep \"$setname\" |wc -l`);
                      #print "Running_Jobs $myjobs\n";
                   }
                }
                if($post_script ne "")
                {
                   system($post_script);
                }

               if($nomail == 0)
               {
                  print("$local_sims -iccrunpath/$regr_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string\n");
                  system("$local_sims -status=$runpath/$regr_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string");

                  if($runpath =~ /scratch/)
                  {
                  }
                  else
                  {
                     if($nocopy == 1)
                     {
                        $copy_runpath = "$runpath";
                     }
                     else
                     {
                        print("Now moving $runpath/$regr_dir to $copy_runpath\n");
                        system("mv $runpath/$regr_dir $copy_runpath");
                     }
                  }
                   print("Log file(s) located under $copy_runpath/$regr_dir\n\n");
                   print("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string\n");
                   system("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -status_loop -status_mail -mail=$mail_receipients -status_freq=$status_freq -norun $rerun_failed_string $legacy_string");
               }
               else
               {
                  if($runpath =~ /scratch/)
                  {
                  }
                  else
                  {
                     if($nocopy == 1)
                     {
                        $copy_runpath = "$runpath";
                     }
                     else
                     {
                        print("Now moving $runpath/$regr_dir to $copy_runpath\n");
#                    if(-d "$copy_runpath/$regr_dir")
#                    {
#                       system("rm -rf $copy_runpath/$regr_dir");
#                    }
                        system("mv $runpath/$regr_dir $copy_runpath");
                     }
                  }
                  print("Log file(s) located under $copy_runpath/$regr_dir\n\n");
                 if($merge_coverage)
                 {
                   print("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -cov_merge=$merge_cov_tool -old_cov_rpt=$ena_old_cov_merge -norun $rerun_failed_string $legacy_string\n");
                   system("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -cov_merge=$merge_cov_tool -old_cov_rpt=$ena_old_cov_merge -norun $rerun_failed_string $legacy_string");
                 }
                 else
                 {
                   print("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -norun $rerun_failed_string $legacy_string\n");
                   system("$local_sims -status=$copy_runpath/$regr_dir $ignoresimerror -norun $rerun_failed_string $legacy_string");
                 }
               }
           }
       }
   }
   else
   {
      if($testname ne "")
      {
         @modified_testname = split(/\./,$testname);
         $logfile = "$modified_testname[0]";
         $dumpfile = "$modified_testname[0]";
         if($seed_passed == 1 && $random_seed == 0)
         {
            $logfile .= "_$seed_value";
            $dumpfile .= "_$seed_value";
         }
         elsif($seed_passed == 0 && $random_seed == 0)
         {
            $seed_value = 1;
            $logfile .= "_1";
            $dumpfile .= "_1";
         }
         else
         {
            $seed_value = int(rand(1000000));
            $logfile .= "_$seed_value";
            $dumpfile .= "_$seed_value";
         }
      }
      else
      {
         $dumpfile = "$dumpfile";
         if($seed_passed == 1 && $random_seed == 0)
         {
            $logfile .= "_$seed_value";
            $dumpfile .= "_$seed_value";
         }
         elsif($seed_passed == 0 && $random_seed == 0)
         {
            $seed_value = 1;
            $logfile .= "_1";
            $dumpfile .= "_1";
         }
         else
         {
            $seed_value = int(rand(1000000));
            $logfile .= "_$seed_value";
            $dumpfile .= "_$seed_value";
         }
      }
      if($logID ne "")
      {
         $logfile .= "\.$logID";
         $dumpfile .= "\.$logID";
      }
      if($dump == 1)
      {
         $dumpopts .= " +dump_file_name=$dumpfile ";
      }
      if($run64 == 1)
      {
         if($whichrun eq "ncv")
         {
            $runcmd = "irun -64bit -R -nclibdirname $build_dir/INCA64_$model_name -l $logfile\.log -licqueue $simulator_run_args $dumpopts $extra_irunOpts ";
            $runcmd .= " -svseed $seed_value +seed=$seed_value ";
            if(! (-e "$build_dir/INCA64_$model_name"))
            {
               die("64 bit model for NCV does not exist under $build_dir. Please build first");
            }
         }
         elsif($whichrun eq "vcs")
         {
            $runcmd = "$build_dir/simv64_$model_name -l $logfile\.log $simulator_run_args $dumpopts ";
            $runcmd .= " +ntb_random_seed=$seed_value ";
            if(! (-e "$build_dir/simv64_$model_name"))
            {
               die("64 bit model for VCS does not exist. Please build first");
            }
         }
         else
         {
            if($simulator_run_args =~ /\+dump/ || $dumpopts =~ /\+dump_all/)
            {
               if($coverage == 1)
               {
                  if($qwave_arg eq "")
                  {
                     $runcmd = "vsim -suppress 3819 -suppress 7041 -qwavedb=+signal -load_elab $build_dir\/$model_name\_elab -batch -suppress 3829,3881 -coverage -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do ";
                  }
                  else
                  {
                     $runcmd = "vsim -suppress 3819 -suppress 7041 -qwavedb=$qwave_arg -load_elab $build_dir\/$model_name\_elab -batch -suppress 3829,3881 -coverage -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do";
                  }
               }
               else
               {
                  if($qwave_arg eq "")
                  {
                     $runcmd = "vsim -suppress 3819 -suppress 7041 -qwavedb=+signal -load_elab $build_dir\/$model_name\_elab -batch -suppress 3829,3881 -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do ";
                  }
                  else
                  {
                     $runcmd = "vsim -suppress 3819 -suppress 7041 -qwavedb=$qwave_arg -load_elab $build_dir\/$model_name\_elab -batch -suppress 3829,3881 -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do ";
                  }
               }
            }
            else
            {
               if($coverage == 1)
               {
#                  $runcmd = "vsim -c -suppress 3829 -debugdb=\"$model_name\.dbg\" -coverage -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log $model_name\_top -lib $build_dir/work -do dofile.do ";
                  $runcmd = "vsim -suppress 3819 -suppress 7041 -load_elab $build_dir\/$model_name\_elab -batch -suppress 3829,3881 -coverage -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do ";
               }
               else
               {
#                  $runcmd = "vsim -c -suppress 3829 -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log $model_name\_top -lib $build_dir/work -do dofile.do ";
                  $runcmd = "vsim -suppress 3819 -suppress 7041 -load_elab $build_dir\/$model_name\_elab -batch  -suppress 3829,3881 -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do ";
               }
            }
            $runcmd .= " -sv_seed $seed_value ";
            if(! (-e "$build_dir/$model_name"))
            {
               die("64 bit model for questa does not exist. Please build first");
            }
         }
      }
      else
      {
         if($whichrun eq "ncv")
         {
            $runcmd = "irun -R -nclibdirname $build_dir/INCA_$model_name -l $logfile\.log -licqueue $simulator_run_args $dumpopts $extra_irunOpts ";
            $runcmd .= " -svseed $seed_value  +seed=$seed_value ";
            if(! (-e "$build_dir/INCA_$model_name"))
            {
               die("model for NCV does not exist. Please build first");
            }
         }
         elsif($whichrun eq "vcs")
         {
            $runcmd = "$build_dir/simv_$model_name -l $logfile\.log $simulator_run_args $dumpopts ";
            $runcmd .= " +ntb_random_seed=$seed_value ";
            print "runcmd = $runcmd\n";
            if(! (-e "$build_dir/simv_$model_name"))
            {
               die("model for VCS does not exist. Please build first");
            }
         }
         else
         {
            if($simulator_run_args =~ /\+dump/ || $dumpopts =~ /\+dump_all/)
            {
               if($coverage == 1)
               {
                  $runcmd = "vsim -suppress 3819 -suppress 7041 -qwavedb -load_elab $build_dir\/$model_name\_elab -batch -suppress 3829,3881 -coverage -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do ";
               }
               else
               {
                  $runcmd = "vsim -suppress 3819 -suppress 7041 -qwavedb -load_elab $build_dir\/$model_name\_elab -batch -suppress 3829,3881 -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do ";
               }
            }
            else
            {
               if($coverage == 1)
               {
#                  $runcmd = "vsim -c -suppress 3829 -debugdb=\"$model_name\.dbg\" -coverage -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log $model_name\_top -lib $build_dir/work -do dofile.do ";
                  $runcmd = "vsim -suppress 3819 -suppress 7041 -load_elab $build_dir\/$model_name\_elab -batch -suppress 3829,3881 -coverage -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do ";
               }
               else
               {
#                  $runcmd = "vsim -c -suppress 3829 -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log $model_name\_top -lib $build_dir/work -do dofile.do ";
                  $runcmd = "vsim -suppress 3819 -suppress 7041 -load_elab $build_dir\/$model_name\_elab -batch -suppress 3829,3881 -onfinish stop $simulator_run_args $dumpopts $extra_questaOpts -l $logfile\.log -do dofile.do ";
               }
            }
            $runcmd .= " -sv_seed $seed_value ";
            if(! (-e "$build_dir/$model_name"))
            {
               die("32 bit model for questa does not exist. Please build first");
            }
         }

      }
      if($testname eq "")
      {
         $final_rundir = $runpath/$rundir;
         if($postscript ne "")
         {
            $final_rundir .= "_$postscript";
         }
         if($clean == 1)
         {
            print "Will delete everything under $final_rundir\n";
            system("rm -rf $final_rundir");
         }
         system("mkdir -p $final_rundir");
         if($extra_irunOpts =~ /-input (.*)\.tcl/)
         {
            system("cp $1\.tcl $runpath/$rundir");
         }
         if($extra_questaOpts =~ /-input (.*)\.tcl/)
         {
            system("cp $1\.tcl $runpath/$rundir");
         }
         if($cpf_passed == 1)
         {
            system("cp $cpf $final_rundir");
         }
         if($upf_passed == 1)
         {
            system("cp $upf $final_rundir");
         }

         chdir("$final_rundir");
         if(-e "$logfile\.log")
         {
            system("mv $logfile\.log $logfile\.old");
         }
         $setname = "$rundir";
      }
      else
      {
         $runcmd .= " +UVM_TESTNAME=$modified_testname[0] ";
         $final_rundir = "$runpath/$rundir/$modified_testname[0]";
         if($postscript ne "")
         {
            $final_rundir .= "_$postscript";
         }
         if($clean == 1)
         {
            print "Will delete everything under $final_rundir\n";
            system("rm $final_rundir/*");
         }
         system("mkdir -p $final_rundir");
         if($extra_irunOpts =~ /-input (.*)\.tcl/)
         {
            system("cp $1\.tcl $runpath/$rundir/$modified_testname[0]");
         }
         if($extra_questaOpts =~ /-input (.*)\.tcl/)
         {
            system("cp $1\.tcl $runpath/$rundir/$modified_testname[0]");
         }

         if($cpf_passed == 1)
         {
            system("cp $cpf $final_rundir");
         }
         if($upf_passed == 1)
         {
            system("cp $upf $final_rundir");
         }

         chdir("$final_rundir");
#         print "MOVING TO $runpath/$rundir/$modified_testname[0]\n";
         if(-e "$logfile\.log")
         {
            system("mv $logfile\.log $logfile\.old");
         }
         $setname = "$rundir";;
      }
      if($run == 1)
      {
         open("RERUN",">","rerun");
         print RERUN "$runcmd \$*\n";
         close(RERUN);
         open(SIMS,">","sims_rerun");
         print SIMS "sims $sims_command\n";
         close(SIMS);
         chmod(0755,"rerun");
         chmod(0755,"sims_rerun");
         open("RERUN_GRID_DUMP", ">","rerun_grid_dump");
         open("RERUN_DUMP",">","rerun_dump");
         print RERUN_DUMP "$runcmd +dump_all \$*\n";
         close(RERUN_DUMP);
         chmod(0755,"rerun_dump");
         open(WAVE,">","openwave");
         if($whichrun eq "questa")
         {
            if($glitch == 1)
            {
               print WAVE "vis +designfile+$build_dir/$model_name\.bin +wavefile+$final_rundir/qwave.db -showglitch \$* \&\n";
            }
            else
            {
               print WAVE "vis +designfile+$build_dir/$model_name\.bin +wavefile+$final_rundir/qwave.db \$* \&\n";
            }
             open(DOFILE,">","dofile.do");
             print DOFILE "onbreak {resume}\n";
             print DOFILE "simstats\n";
             if($coverage == 1)
             {
                print DOFILE "coverage save -onexit -testname $logfile $logfile.ucdb\n";
             }
             print DOFILE "set PrefMain(LinePrefix) \"\"\n";
             print DOFILE "run -all\n";
             print DOFILE "simstats\n";
             print DOFILE "quit -f\n";
             close(DOFILE);
         }
         else
         {
            print WAVE "simvision $final_rundir/*.shm \$* \&\n";
         }
         close(WAVE);
         chmod(0755,"openwave");

#      print "Will execute command $runcmd\n";
         if($grid == 1)
         {
#            sleep(1);
#         my $num_jobs = `nc list -u $user -dir . | wc -l`;
#         if($num_jobs > 0)
#         {
#            $num_jobs = $num_jobs - 1;
#         }
##               print "Jobs already submitted = $num_jobs and throttle = $throttle\n";
            #
#         while($num_jobs >= $throttle)
#         {
##                    sleep(1);
#            $num_jobs = `nc list -u $user -dir . | wc -l`;
#            $num_jobs = $num_jobs - 1;
#         }
            if($runcmd =~ /string2warning=\"(.*)\" /)
            {
               my @tmpstrings = split(/\+/,$1);
               my @joinstrings;
               my $tmpmodstrings;
               foreach my $tmp (@tmpstrings)
               {
                  $tmp =~ s/\"/\\"/g;
                  $tmp =~ s/ /\\ /g;
                  push(@joinstrings,$tmp);
               }
               $tmpmodstrings = join("+",@joinstrings);
               $runcmd =~ s/string2warning=\"(.*)\"/string2warning=\\\"$tmpmodstrings\\\" /;
            }

            if($runcmd =~ /block2warning=\"(.*)\" /)
            {
               my @tmpblocks = split(/\,/,$1);
               my @joinblocks;
               my $tmpmodblocks;
               foreach my $tmp (@tmpblocks)
               {
                  $tmp =~ s/\"/\\"/g;
                  $tmp =~ s/ /\\ /g;
                  push(@joinblocks,$tmp);
               }
               $tmpmodblocks = join("+",@joinblocks);
               $runcmd =~ s/block2warning=\"(.*)\"/block2warning=\\\"$tmpmodblocks\\\" /;
            }

            if($check_status == 0)
            {
               #print("Throttle is $throttle\n");
               if($script ne "")
               {
                  system("$script $final_rundir $modified_testname[0]");
               }
               if($whichrun eq "ncv")
               {
                  my @tmp_cpf = split(/\//,$cpf);
                  my $tmp_cpf_size = @tmp_cpf;
                  my $tmp_cpf_file = $tmp_cpf[$tmp_cpf_size - 1];
                  if($cpf_passed == 1)
                  {
                     $runcmd .= " -lps_cpf $tmp_cpf_file ";
                  }
               }
               else
               {
                  my @tmp_upf = split(/\//,$upf);
                  my $tmp_upf_size = @tmp_upf;
                  my $tmp_upf_file = $tmp_upf[$tmp_upf_size - 1];
                  if($upf_passed == 1)
                  {
                     $runcmd .= " -pa $tmp_upf_file ";
                  }
               }

               my $tmp_runcmd = $runcmd;
               $tmp_runcmd .= " +dump_all ";
               print RERUN_GRID_DUMP "nc run -p $job_priority $job_group -C $job_q -set $setname -nolog -D -limit $user $throttle -r $resource -- \"$tmp_runcmd\" \$*";
               close(RERUN_GRID_DUMP);
               chmod(0755,"rerun_grid_dump");
               print "runcmd grid job $runcmd\n";
               &submit_grid_jobs($job_priority,$job_group,$job_q,$setname,$throttle,$resource,"$runcmd",$max_run_time);
            }
         }
         else
         {
            # FIXME - No disk space check if run local
            if($script ne "")
            {
               system("$script $final_rundir $modified_testname[0]");
            }
            my @tmp_cpf = split(/\//,$cpf);
            my $tmp_cpf_size = @tmp_cpf;
            my $tmp_cpf_file = $tmp_cpf[$tmp_cpf_size - 1];
            if($cpf_passed == 1)
            {
               $runcmd .= " -lps_cpf $tmp_cpf_file ";
            }
            print "Run command is $runcmd\n";
            system($runcmd);
         }
      }
   }


   if($tl_run == 0 && $check_status == 0 && $testlist_passed == 0)
   {
      if($wait == 1 && $grid == 1)
      {
         print("Will be waiting on $setname\n");
         sleep(5);
         my  $myjobs = (`bjobs -w | grep "PEND" | grep \"$setname\" |wc -l` + `bjobs -w | grep "RUN" | grep \"$setname\" |wc -l`);
         my $totaljobs = $myjobs;
         my $pendingjobs;
         my $runningjobs;
         my $failingjobs;
         while ($myjobs >0) {
           sleep(10);
           $myjobs = (`bjobs -w | grep "PEND" | grep \"$setname\" |wc -l` + `bjobs -w | grep "RUN" | grep \"$setname\" |wc -l`);
           #print "Running_Jobs $myjobs\n";
      	 }
      }
      if($grid == 0)
      {
         if($legacy == 1)
         {
            system("$local_sims -status=$final_rundir $ignoresimerror $legacy_string");
         }
#         print("Will call $local_sims -status=$final_rundir -min_status");
         else
         {
            system("$local_sims -status=$final_rundir $ignoresimerror -min_status $legacy_string");
         }
      }
      else
      {
#         print("Will call $local_sims -status=$final_rundir");
         system("$local_sims -status=$final_rundir $ignoresimerror $legacy_string");
      }
      ## Copy files to copy_runpath
#      print("Moving files from $final_rundir to $copy_runpath\n");
#      my @tmp = split('/',$final_rundir);

      print("Log file(s) under $final_rundir\n\n");
   }
}


sub help
{
   print "sims <options>\n";
   print "<options>\n";
   print "MAKE SURE YOUR TB_ROOT is SET PROPERLY to your testbench base directory under which you have tb,env,sv,tests dorectory\n";
   print "Your filelist should be under \$TB_ROOT/vflist\n";
   print "Your testlist should be under \$TB_ROOT/tests\n";
   print "If a test passes make sure to print PASSED towards the end of the simulation\n";
   print "If a test fails make sure to print TEST FAILED at the end of the simulation\n";
   print "     -build                  Builds a model using 32 bit NC sim\n";
   print "     -build64                Builds a model using 64 bit NC sim\n";
   print "     -d/-define=<define>     Passing a pre-processor define for +define+\n";
   print "     -fl=<flist>             Passing a User file list. If this is not passed either block.fl or tb.fl will be searched for under \$TB_ROOT/vflist\n";
   print "     -f=<file>               Passing a single file instead of the flist\n";
   print "     -test=<testname>        Pass the test template for SLTB/MLTB.\n";
   print "     -tl=<testlist>          Pass the testlist for regression. This MUST be under \$TB_ROOT/tests\n";
   print "     -regr=<REGR>            This is the regression you want to run in the .tl file. In the .tl your section will be REGR_BEGIN and REGR_END\n";
   print "     -run_dir=<dir>          Run under directory \$runpath/<dir> where \$runpath defaults to /server/scratch/\$user/sim\n";
   print "     -N=<postscript>         If a user wants to run the same test, but in a separate directory, passing this will add _N to the directory name\n";
   print "     -run_path=<dir>         Create simulation/test run directories under this path. This defaults to /server/scratch/\$user/sim\n";
   print "     -run                    If users want to run something along with the -status option\n";
   print "     -run64                  When the user builds something in 64 bit compiler, this is the command to run the corresponding executable\n";
   print "     -build_dir=<dir>        Build model under \$TB_ROOT\/<dir>\n";
   print "     -build_path=<dir>       Create the build_dir directory under build_path. Defaults to \$TB_ROOT\n";
   print "     -model_name=name        Creates a model name as INCA_model_name\n";
   print "     -seed=<seed>            Specify the seed you want to run with. Default seed is 1\n";
   print "     -bargs=args             Specify build specific options for the compiler you are running\n";
   print "     -rargs=args             Specify run arguments for the compiler you are running\n";
   print "     -oargs=args             Optimization arguments more specifically for the questa compiler\n";
   print "     -eargs=args             Elaboration arguments for the compiler you are running\n";
   print "     -ignoresimerror         Ignore simulator specific errors when deciding test pass/fail status\n";
   print "     -irun_b_opts=opts       Specify build specific irun options like passing a tcl file, coverage, etc\n";
   print "     -irun_r_opts=opts       Specify run specific irun options like passing a tcl file, coverage, etc\n";
   print "     -questa_b_opts=opts     Specify build specific questa options like passing a tcl file, coverage, etc\n";
   print "     -questa_r_opts=opts     Similar to irun_r_opts, except this is for the questa tool during vsim run\n";
   print "     -questa_vopt_args=opts  These arguments are passed to the optimization step (vopt) of questa sim\n";
   print "     -questa_elab_opts=opts  These arguments are specifically passed to the vsim during elaboration\n";
   print "     -num_tests=<num>        This is used to specify number of tests to run in the regression. Users can then use the inbuilt \$num_tests\n";
   print "                             variable within a perl routine to randomize tests/arguments\n";
   print "     -noassert               Disable concurrent and immediate assertions\n";
   print "     -rseed                  If users want a random seed generated by the script. DONT PASS -seed along with this argument\n";
   print "     -clean                  Clean build/run\n";
   print "     -norun                  Dont run any test\n";
   print "     -nobuild                Dont build\n";
   print "     -nocopy                 Pass this argument if you dont want sims to copy back regression results to the scratch area.\n";
   print "     -p=<priority>           Job priority for submission to grid. Can be low,normal,high,top or a number between 1-12\n";
   print "     -R=<resource>           Resource to check for before submitting a job\n";
   print "     -g=<group>              Grid group to submit the job to\n";
   print "     -q=<short/long/regr>    Grid queue to submit jobs on (short/long/regr). Short Q jobs are auto killed after 1 hr.\n";
   print "                             Long Q jobs are never terminated. Regr Q jobs are terminated after 2 hrs\n";
   print "     -maxjobs=<max jobs>     Throttles the MAX number of jobs that can be submitted to the grid\n";
   print "     -grid                   Submit the job to the grid\n";
   print "     -dump[=<options>,...]   Comma separated options are one of the following\n";
   print "                             memory - Dump memory contents to the waveform\n";
   print "                             glitch - Enable zero delay glitch detection in Questa qwave waveform\n";
   print "                             transactions - Capture UVM transactions\n";
   print "                             assertions - Capture full assertions in the waveform\n";
   print "                             cells - Dump cells and FSM\n";
   print "                             messages - Create message mode display of Log files\n";
   print "     -mail[=email1,email2]   Send status email to the job submitter after all the jobs are complete or to each of the email addresses\n";
   print "                             specified in the optional comma separated list\n";
   print "     -status_freq=<N>        Send status email to the submitter or the optional comma separated list every N minutes\n";
   print "     -status[=directory]     Collect run status on the optional directory path passed\n";
   print "     -rerun_failed           Rerun the shortest failing test under each bucket with dumping turned on\n";
   print "     -cpf=<CPF file>         Absolute path to the CPF file for low power verification\n";
   print "     -upf=<UPF file>         Absolute path to the UPF file for low power verification with questa/VCS\n";
   print "     -pre_script=<script>    Absolute path of the pre-processing script to be run before firing off the test/regression\n";
   print "     -script=<script>        Absolute path of the script to be run along with the test/regression\n";
   print "     -post_script=<script>   Absolute path of the post-processing script to be run after a test or regression is completed\n";
   print "     -legacy                 For usage with older purely verilog based legacy testbenches\n";
   print "     -ncv                    For building with the Cadence Incisive compiler\n";
   print "     -vcs                    For building with the Synopsys VCS compiler\n";
   print "     -questa                 For building with the Mentor Questa compiler\n";
   print "     -gui                    Open sims gui\n";
   print "     -h/-help                Prints out the help menu\n";
}
