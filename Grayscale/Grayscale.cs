using System;

namespace UnityEngine.Rendering.HighDefinition
{
    [Serializable, VolumeComponentMenu("Post-processing/Grayscale")]
    public sealed class Grayscale : CustomPostProcessVolumeComponent, IPostProcessComponent
    {
        // Grayscale Rec formula conversion (https://en.wikipedia.org/wiki/Luma_(video)).
        public enum Formula
        {
            Rec601,
            Rec709,
            Average,
            Lightness
        }

        public BoolParameter enable = new BoolParameter(false, true);

        [Tooltip("Grayscale Rec formula conversion (https://en.wikipedia.org/wiki/Luma_(video)).")]
        public GrayscaleModeParameter formula = new GrayscaleModeParameter(Formula.Rec601);

        private Material m_Material = null;

        public bool IsActive()
        {
            return m_Material != null && enable.value;
        }

        public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

        public override void Setup()
        {
            if (Shader.Find("Hidden/Shader/GrayscalePostProcess") != null)
            {
                m_Material = new Material(Shader.Find("Hidden/Shader/GrayscalePostProcess"));
            }
        }

        public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
        {
            if (!enable.value || m_Material == null)
            {
                return;
            }

            switch (formula.value)
            {
                case Formula.Rec601:
                    cmd.Blit(source, destination, m_Material, 0);
                    break;

                case Formula.Rec709:
                    cmd.Blit(source, destination, m_Material, 1);
                    break;

                case Formula.Average:
                    cmd.Blit(source, destination, m_Material, 2);
                    break;

                case Formula.Lightness:
                    cmd.Blit(source, destination, m_Material, 3);
                    break;
            }
        }

        public override void Cleanup()
        {
            CoreUtils.Destroy(m_Material);
        }
    }

    [Serializable]
    public sealed class GrayscaleModeParameter : VolumeParameter<Grayscale.Formula>
    {
        public GrayscaleModeParameter(Grayscale.Formula value, bool overrideState = false) : base(value, overrideState) { }
    }
}