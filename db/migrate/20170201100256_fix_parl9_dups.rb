class FixParl9Dups < ActiveRecord::Migration
  # parliament loaded a June 2016 file in December 2016 and assigned the file to the new parliament and not the old parliament
  # this created a new set of delegates in parl9 with the same xmlid as those in parl8 
  # -> this is bad for there are now two records for many delegates in parl9 and the votes from the June file are assigned to the wrong parliament
  # to fix this, the following is needed:
  # - fix otar dup in parl8
  # - fix delegate ids for the one file and assign file to parl8
  # - merge parl9 duplicates
  # - if delegates from bad file still exist, delete them
  # - update law/delegate counts for parl 8 and 9
  
  def up
    start = Time.now

    # id of file that was assigned the wrong parliament
    # there are two ids because one file was deleted
    file_ids = [378, 379]

    # fix duplicate otar records in parl8
    parl8_dup_ids = [339, 76]

    parl8_ids = [
      [3, 462], [4, 463], [5, 464], [6, 465], [7, 466], [8, 467], [9, 532], [11, 468], [12, 469], [15, 470], [17, 472], [18, 473], [20, 534], [22, 474], [24, 475], [25, 476], [26, 477], [27, 478], [28, 481], [29, 482], [30, 536], [31, 546], [32, 487], [33, 488], [34, 489], [36, 490], [37, 537], [38, 538], [40, 493], [41, 494], [42, 495], [43, 539], [44, 540], [45, 496], [47, 497], [48, 549], [50, 498], [51, 499], [52, 500], [53, 501], [54, 503], [55, 505], [56, 506], [57, 507], [58, 509], [60, 510], [61, 511], [62, 542], [64, 513], [65, 514], [66, 515], [67, 516], [68, 517], [69, 518], [71, 519], [73, 520], [74, 548], [77, 522], [79, 523], [80, 479], [88, 480], [94, 484], [95, 485], [100, 508], [102, 512], [104, 531], [105, 545], [107, 491], [109, 541], [120, 486], [123, 502], [124, 504], [129, 483], [139, 471], [142, 535], [144, 547], [145, 492], [157, 533], [325, 543], [326, 524], [327, 544], [331, 525], [332, 526], [335, 527], [336, 528], [337, 529], [338, 530], [339, 521]
    ]

    bad_parl9_ids = [
      462, 463, 464, 465, 466, 467, 532, 468, 469, 470, 472, 473, 534, 474, 475, 476, 477, 478, 481, 482, 536, 546, 487, 488, 489, 490, 537, 538, 493, 494, 495, 539, 540, 496, 497, 549, 498, 499, 500, 501, 503, 505, 506, 507, 509, 510, 511, 542, 513, 514, 515, 516, 517, 518, 519, 520, 548, 521, 522, 523, 479, 480, 484, 485, 508, 512, 531, 545, 491, 541, 486, 502, 504, 483, 471, 535, 547, 492, 533, 543, 524, 544, 525, 526, 527, 528, 529, 530, 521
    ]

    parl9_ids = [
      [347, 465], [348, 466], [350, 532], [361, 473], [370, 475], [436, 476], [374, 478], [450, 482], [407, 487], [553, 490], [556, 495], [443, 539], [418, 501], [423, 503], [424, 507], [427, 511], [449, 542], [426, 548], [552, 479], [405, 485], [431, 531], [394, 545], [554, 491], [406, 486], [421, 502], [562, 504], [551, 471], [369, 544], [445, 521]
    ]


    AllDelegate.transaction do
      puts "fixing name duplicate from parl8"
      # keep the more recent id for it is the correct spelling
      AllDelegate.merge_delegates(parl8_dup_ids[0], parl8_dup_ids[1], false)
      puts "- reseting started at to nil"
      del = AllDelegate.find(parl8_dup_ids[0])
      del.started_at = nil
      del.save

      puts "updating parliament id for file"
      file_ids.each do |file_id|
        file = UploadFile.where(id: file_id).first
        file.parliament_id = 1
        file.save

        puts "- updating bad delegate ids in the file"
        file.conference.delegates.each do |delegate|
          del_index = parl8_ids.index{|x| delegate.all_delegate_id == x[1]}
          if del_index.present?
            correct_delegate = AllDelegate.where(:id => parl8_ids[del_index][0]).first
            if correct_delegate.present?
              puts "-- updating #{delegate.id} from all delegate #{delegate.all_delegate_id} to #{correct_delegate.id}"
              # found the correct delegate -> update the existing record with the correct data
              delegate.all_delegate_id = correct_delegate.id
              delegate.first_name = correct_delegate.first_name_ka
              delegate.xml_id = correct_delegate.xml_id
              delegate.group_id = correct_delegate.xml_id
              delegate.title = correct_delegate.title
              delegate.save
            end
          end
        end

      end

      puts "merging duplicates for parl9"
      parl9_ids.each_with_index.each do |id, index|
        AllDelegate.merge_delegates(id[0], id[1], false)
      end

      puts "deleting the remaining bad delegates from parl9 that did not have a new parl9 record"
      # if delegate records exists, delete it and any voting result records that exist
      # all of the voting records should indicate that the person was not present
      ds = Delegate.where(all_delegate_id: bad_parl9_ids)
      VotingResult.where(delegate_id: ds.map{|x| x.id}).delete_all
      AllDelegate.where(id: ds.map{|x| x.all_delegate_id}).delete_all
      ds.delete_all

      puts "updating law and delegate counts"
      puts "- parl8"
      Agenda.update_law_vote_results(1)
      AllDelegate.update_vote_counts(1)

      puts "- parl9"
      Agenda.update_law_vote_results(3)
      AllDelegate.update_vote_counts(3)


      # clear out json api files
      FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
    end

    puts "-----------------------------------------------------------------------------"
    puts "Total time for #{parl8_ids.length} records to merge was #{Time.now-start} seconds"
  end

  def down
    puts 'do nothing'
  end
end
