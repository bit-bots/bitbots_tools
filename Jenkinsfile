@Library('bitbots_jenkins_library') import de.bitbots.jenkins.*;

defineProperties()

echo env.CHANGE_BRANCH
echo env.BRANCH_NAME
def x = isPrimaryBranch()
echo "${x}"

def pipeline = new BitbotsPipeline(this, env, currentBuild, scm)
pipeline.configurePipelineForPackage(new PackagePipelineSettings(new PackageDefinition("bitbots_docs"), true, true, !isChangeRequest()))
pipeline.execute()
