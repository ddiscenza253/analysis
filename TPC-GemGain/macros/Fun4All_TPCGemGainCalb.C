#include <GlobalVariables.C>

#include <TPCGemGainCalb.h>

#include <G4Setup_sPHENIX.C>
#include <G4_Bbc.C>
#include <G4_CaloTrigger.C>
#include <G4_DSTReader.C>
#include <G4_Global.C>
#include <G4_HIJetReco.C>
#include <G4_Input.C>
#include <G4_Jets.C>
#include <G4_ParticleFlow.C>
#include <G4_Production.C>
#include <G4_TopoClusterReco.C>
#include <G4_User.C>
#include <fun4all/Fun4AllDstOutputManager.h>
#include <fun4all/Fun4AllOutputManager.h>
#include <fun4all/Fun4AllServer.h>

#include <phool/PHRandomSeed.h>
#include <phool/recoConsts.h>

R__LOAD_LIBRARY(libfun4all.so)

int Fun4All_TPCGemGainCalb(
			  const int process = 1,
			  const int nEvents  = 0,
			  const string &embed_input_str1 = "Pass2_out_0",
			  //const string &embed_input_str1 = "Reco_DST-0",
			  //const string &embed_input_str1 = "my_Reco_DST-0",
			  //const string &embed_input_str1 = "chris_Reco_DST-0",
			  const string &outputFile_str = "TrackReadback_0",
			  const int skip = 0,
			  const string &outdir = ".")
{
  Fun4AllServer *se = Fun4AllServer::instance();
  se->Verbosity(1);



  // construct the input and output file names
  char num_field[500];
  sprintf(num_field,"%04d.root", process);
  string numin = num_field;
  //string embed_infile1 = embed_input_str1+numin;
  string embed_infile1 = "/sphenix/user/ddiscenza/Work/June8/macros/macros/detectors/sPHENIX/G4sPHENIX.root";
  string outputFile = outputFile_str+numin;

  cout << "input file1: " << embed_infile1 << endl;
  cout << "outputFile: " << outputFile << endl;

 // just if we set some flags somewhere in this macro
  recoConsts *rc = recoConsts::instance();

  Input::READHITS = true;
  Input::VERBOSITY = 10;
  INPUTREADHITS::filename[0] = embed_infile1;

  // Reads in the file
  InputManagers();

  TPCGemGainCalb *track_readback = new TPCGemGainCalb();
  track_readback->Verbosity(0);
  se->registerSubsystem(track_readback);


  //se->skip(skip);
  se->run(nEvents);
  se->PrintTimer();
  //-----
  // Exit
  //-----

  se->End();
  std::cout << "All done" << std::endl;
  delete se;

return 0;
}
